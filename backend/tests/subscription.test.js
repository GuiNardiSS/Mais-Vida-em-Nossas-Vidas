import jwt from 'jsonwebtoken';
import request from 'supertest';

import Subscription from '../models/Subscription.js';
import {
  DEVICE_A,
  DEVICE_B,
  seedPayment,
  seedSubscription,
  startTestContext,
} from './helpers/context.js';

const DAY_MS = 86_400_000;

describe('Assinatura - entitlement, validação, expiração e cancelamento', () => {
  let ctx;

  beforeAll(async () => {
    ctx = await startTestContext();
  });

  afterAll(async () => {
    await ctx.close();
  });

  const activate = (body) =>
    request(ctx.app).post('/api/v1/subscription/activate').send(body);

  it('rejeita ativação apenas com transactionId arbitrário (400)', async () => {
    const response = await activate({
      deviceId: DEVICE_A,
      transactionId: 'qualquer-coisa-123',
      paymentMethod: 'pix',
      amount: 499,
    });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('PAYMENT_REQUIRED');
    expect(response.body.error.message).toContain('paymentId');

    const subscription = await Subscription.findOne({ deviceId: DEVICE_A });
    expect(subscription).toBeNull();
  });

  it('rejeita paymentId inexistente (404)', async () => {
    const response = await activate({
      deviceId: DEVICE_A,
      paymentId: '665f2b0f5f1b2c0012345678',
    });

    expect(response.status).toBe(404);
    expect(response.body.error.code).toBe('PAYMENT_NOT_FOUND');
  });

  it('rejeita ativação com pagamento pendente (409)', async () => {
    const payment = await seedPayment({ deviceId: 'sub-pending-device' });

    const response = await activate({
      deviceId: 'sub-pending-device',
      paymentId: payment.id,
    });

    expect(response.status).toBe(409);
    expect(response.body.error.code).toBe('PAYMENT_NOT_PAID');
    expect(response.body.error.details.status).toBe('pending');
  });

  it('rejeita pagamento de outro dispositivo (403)', async () => {
    const payment = await seedPayment({
      deviceId: DEVICE_A,
      status: 'paid',
      paidAt: new Date(),
    });

    const response = await activate({
      deviceId: DEVICE_B,
      paymentId: payment.id,
    });

    expect(response.status).toBe(403);
    expect(response.body.error.code).toBe('PAYMENT_DEVICE_MISMATCH');
  });

  it('ativa com pagamento pago, gera JWT e é idempotente por pagamento', async () => {
    const deviceId = 'sub-active-device';
    const payment = await seedPayment({
      deviceId,
      amount: 999,
      status: 'paid',
      paidAt: new Date(),
    });

    const first = await activate({ deviceId, paymentId: payment.id });

    expect(first.status).toBe(201);
    expect(first.body.success).toBe(true);
    expect(first.body.activated).toBe(true);
    expect(first.body.subscription).toMatchObject({
      isActive: true,
      status: 'active',
      daysRemaining: 30,
    });
    expect(first.body.subscription.deviceId).toBe('sub-acti...');

    const decoded = jwt.verify(first.body.token, ctx.env.JWT_SECRET);
    expect(decoded.deviceId).toBe(deviceId);
    expect(decoded.type).toBe('device');

    const expiry = first.body.subscription.expiryDate;
    const second = await activate({ deviceId, paymentId: payment.id });

    expect(second.status).toBe(200);
    expect(second.body.activated).toBe(false);
    expect(second.body.subscription.expiryDate).toBe(expiry);
  });

  it('valida assinatura ativa pelo contrato antigo', async () => {
    const deviceId = 'sub-validate-device';
    const payment = await seedPayment({
      deviceId,
      status: 'paid',
      paidAt: new Date(),
    });
    await activate({ deviceId, paymentId: payment.id });

    const response = await request(ctx.app)
      .post('/api/v1/subscription/validate')
      .send({ deviceId });

    expect(response.status).toBe(200);
    expect(response.body.isActive).toBe(true);
    expect(response.body.status).toBe('active');
    expect(response.body.daysRemaining).toBeGreaterThanOrEqual(29);
  });

  it('retorna status free quando não existe assinatura', async () => {
    const response = await request(ctx.app)
      .post('/api/v1/subscription/validate')
      .send({ deviceId: 'sub-no-subscription' });

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      isActive: false,
      status: 'free',
      daysRemaining: 0,
    });
  });

  it('retorna info da assinatura e 404 para desconhecida', async () => {
    const deviceId = 'sub-info-device';
    const payment = await seedPayment({
      deviceId,
      status: 'paid',
      paidAt: new Date(),
    });
    await activate({ deviceId, paymentId: payment.id });

    const info = await request(ctx.app)
      .get('/api/v1/subscription/info')
      .query({ deviceId });

    expect(info.status).toBe(200);
    expect(info.body).toMatchObject({
      isActive: true,
      status: 'active',
      paymentMethod: 'pix',
      amount: 499,
    });
    expect(info.body.startDate).toBeTruthy();
    expect(info.body.createdAt).toBeTruthy();

    const missing = await request(ctx.app)
      .get('/api/v1/subscription/info')
      .query({ deviceId: 'sub-unknown-device' });
    expect(missing.status).toBe(404);
    expect(missing.body.error.code).toBe('SUBSCRIPTION_NOT_FOUND');
  });

  it('cancela assinatura de forma idempotente e invalida acesso', async () => {
    const deviceId = 'sub-cancel-device';
    const payment = await seedPayment({
      deviceId,
      status: 'paid',
      paidAt: new Date(),
    });
    await activate({ deviceId, paymentId: payment.id });

    const cancel = await request(ctx.app)
      .post('/api/v1/subscription/cancel')
      .send({ deviceId, reason: 'teste' });

    expect(cancel.status).toBe(200);
    expect(cancel.body.success).toBe(true);
    expect(cancel.body.alreadyCancelled).toBe(false);
    expect(cancel.body.subscription.status).toBe('cancelled');

    const again = await request(ctx.app)
      .post('/api/v1/subscription/cancel')
      .send({ deviceId });
    expect(again.status).toBe(200);
    expect(again.body.alreadyCancelled).toBe(true);

    const validation = await request(ctx.app)
      .post('/api/v1/subscription/validate')
      .send({ deviceId });
    expect(validation.body.isActive).toBe(false);
    expect(validation.body.status).toBe('cancelled');
  });

  it('método renew(months) soma meses a partir da expiração vigente', async () => {
    const deviceId = 'sub-renew-method-device';
    const subscription = await seedSubscription({
      deviceId,
      status: 'active',
      expiryDate: new Date(Date.now() + 5 * DAY_MS),
    });
    const expected = new Date(subscription.expiryDate);
    expected.setMonth(expected.getMonth() + 1);

    await subscription.renew(1);

    expect(subscription.status).toBe('active');
    expect(subscription.expiryDate.getTime()).toBe(expected.getTime());
  });

  it('expira assinatura vencida ao validar', async () => {    const deviceId = 'sub-expired-device';
    await seedSubscription({
      deviceId,
      status: 'active',
      expiryDate: new Date(Date.now() - 2 * DAY_MS),
    });

    const validation = await request(ctx.app)
      .post('/api/v1/subscription/validate')
      .send({ deviceId });

    expect(validation.status).toBe(200);
    expect(validation.body.isActive).toBe(false);
    expect(validation.body.status).toBe('expired');
    expect(validation.body.daysRemaining).toBe(0);

    const persisted = await Subscription.findOne({ deviceId });
    expect(persisted.status).toBe('expired');
  });

  it('renova somando novo período ao tempo restante, sem dupla extensão', async () => {
    const deviceId = 'sub-renew-device';

    const firstPayment = await seedPayment({
      deviceId,
      status: 'paid',
      paidAt: new Date(),
    });
    const first = await activate({ deviceId, paymentId: firstPayment.id });
    const firstExpiry = new Date(first.body.subscription.expiryDate);

    const secondPayment = await seedPayment({
      deviceId,
      status: 'paid',
      paidAt: new Date(),
    });
    const second = await activate({ deviceId, paymentId: secondPayment.id });
    const secondExpiry = new Date(second.body.subscription.expiryDate);

    expect(second.status).toBe(201);
    expect(second.body.activated).toBe(true);

    const extensionDays = (secondExpiry - firstExpiry) / DAY_MS;
    expect(extensionDays).toBeGreaterThan(29);
    expect(extensionDays).toBeLessThan(31);

    const repeat = await activate({ deviceId, paymentId: secondPayment.id });
    expect(repeat.status).toBe(200);
    expect(new Date(repeat.body.subscription.expiryDate).getTime()).toBe(
      secondExpiry.getTime()
    );
  });

  it('ativa com token de demonstração e rejeita token inválido', async () => {
    const deviceId = 'sub-demo-device';

    const invalid = await activate({ deviceId, demoToken: 'token-errado' });
    expect(invalid.status).toBe(401);
    expect(invalid.body.error.code).toBe('INVALID_DEMO_TOKEN');

    const valid = await activate({
      deviceId,
      demoToken: ctx.env.DEMO_ACTIVATION_TOKEN,
    });
    expect(valid.status).toBe(201);
    expect(valid.body.activated).toBe(true);
    expect(valid.body.subscription.status).toBe('active');

    const repeat = await activate({
      deviceId,
      demoToken: ctx.env.DEMO_ACTIVATION_TOKEN,
    });
    expect(repeat.status).toBe(200);
    expect(repeat.body.activated).toBe(false);
  });

  it('bloqueia token de demonstração quando DEMO_MODE=false', async () => {
    const appWithoutDemo = ctx.buildApp({ DEMO_MODE: 'false' });

    const response = await request(appWithoutDemo)
      .post('/api/v1/subscription/activate')
      .send({
        deviceId: 'sub-demo-disabled',
        demoToken: ctx.env.DEMO_ACTIVATION_TOKEN,
      });

    expect(response.status).toBe(403);
    expect(response.body.error.code).toBe('DEMO_MODE_DISABLED');
  });

  it('mantém aliases legados de /subscription', async () => {
    const deviceId = 'sub-legacy-device';
    const payment = await seedPayment({
      deviceId,
      status: 'paid',
      paidAt: new Date(),
    });

    const activation = await request(ctx.app)
      .post('/subscription/activate')
      .send({ deviceId, paymentId: payment.id });
    expect(activation.status).toBe(201);

    const validation = await request(ctx.app)
      .post('/subscription/validate')
      .send({ deviceId });
    expect(validation.body.isActive).toBe(true);

    const info = await request(ctx.app)
      .get(`/subscription/info/${deviceId}`);
    expect(info.status).toBe(200);
    expect(info.body.isActive).toBe(true);
  });
});
