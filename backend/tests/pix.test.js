import request from 'supertest';

import Payment from '../models/Payment.js';
import { inspectPixPayload, parsePixPayload } from '../services/pixPayload.js';
import { createPixPayment } from '../services/paymentService.js';
import {
  DEVICE_A,
  DEVICE_B,
  buildEnv,
  seedPayment,
  startTestContext,
} from './helpers/context.js';

// Provedores reais (Mercado Pago, Asaas, Efi) não são chamados nos testes:
// exigem credenciais e network externa. O fluxo coberto aqui é o provider mock,
// que é o padrão executável sem configuração.
describe('PIX - criação, status e simulação', () => {
  let ctx;

  beforeAll(async () => {
    ctx = await startTestContext();
  });

  afterAll(async () => {
    await ctx.close();
  });

  const createPix = (overrides = {}) =>
    request(ctx.app)
      .post('/api/v1/payments/pix')
      .send({ deviceId: DEVICE_A, amount: 499, ...overrides });

  it('cria cobrança mock pendente com BR Code EMV válido (CRC16)', async () => {
    const response = await createPix();

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      provider: 'mock',
      method: 'pix',
      status: 'pending',
      amount: 499,
      currency: 'BRL',
      isMock: true,
      entitlementApplied: false,
    });
    expect(response.body.paymentId).toMatch(/^[a-f0-9]{24}$/);
    expect(response.body.copiaECola).toBe(response.body.brCode);
    expect(response.body.transactionId).toMatch(/^[A-Za-z0-9]{1,25}$/);

    const inspection = inspectPixPayload(response.body.brCode);
    expect(inspection.valid).toBe(true);
    expect(inspection.tags['54']).toBe('4.99');
    expect(inspection.tags['26']).toContain('br.gov.bcb.pix');
    expect(inspection.tags['26']).toContain('demo@maisvida.app');
    expect(parsePixPayload(inspection.tags['62'])['05']).toBe(
      response.body.transactionId
    );
  });

  it('consulta o status do pagamento', async () => {
    const created = await createPix();

    const response = await request(ctx.app).get(
      `/api/v1/payments/pix/${created.body.paymentId}`
    );

    expect(response.status).toBe(200);
    expect(response.body.status).toBe('pending');
    expect(response.body.paymentId).toBe(created.body.paymentId);
  });

  it('retorna 404 quando deviceId da query não é o dono do pagamento', async () => {
    const created = await createPix();

    const response = await request(ctx.app)
      .get(`/api/v1/payments/pix/${created.body.paymentId}`)
      .query({ deviceId: DEVICE_B });

    expect(response.status).toBe(404);
    expect(response.body.error.code).toBe('PAYMENT_NOT_FOUND');
  });

  it('rejeita payload inválido com 400 e detalhes do Zod', async () => {
    const noDevice = await request(ctx.app)
      .post('/api/v1/payments/pix')
      .send({ amount: 499 });
    expect(noDevice.status).toBe(400);
    expect(noDevice.body.error.code).toBe('VALIDATION_ERROR');
    expect(noDevice.body.error.details[0].source).toBe('body');

    const lowAmount = await createPix({ amount: 10 });
    expect(lowAmount.status).toBe(400);

    const zeroAmount = await createPix({ amount: 0 });
    expect(zeroAmount.status).toBe(400);
  });

  it('rejeita id inválido (400) e pagamento inexistente (404)', async () => {
    const invalid = await request(ctx.app).get('/api/v1/payments/pix/abc');
    expect(invalid.status).toBe(400);
    expect(invalid.body.error.code).toBe('VALIDATION_ERROR');

    const missing = await request(ctx.app).get(
      '/api/v1/payments/pix/665f2b0f5f1b2c0012345678'
    );
    expect(missing.status).toBe(404);
    expect(missing.body.error.code).toBe('PAYMENT_NOT_FOUND');
  });

  it('simulação desabilitada responde 403 DEMO_MODE_DISABLED', async () => {
    const created = await createPix();
    const appWithoutDemo = ctx.buildApp({ DEMO_MODE: 'false' });

    const response = await request(appWithoutDemo).post(
      `/api/v1/payments/pix/${created.body.paymentId}/simulate`
    );

    expect(response.status).toBe(403);
    expect(response.body.error.code).toBe('DEMO_MODE_DISABLED');
  });

  it('simula pagamento, ativa assinatura e é idempotente', async () => {
    const created = await createPix({ amount: 1999 });

    const first = await request(ctx.app).post(
      `/api/v1/payments/pix/${created.body.paymentId}/simulate`
    );

    expect(first.status).toBe(200);
    expect(first.body.success).toBe(true);
    expect(first.body.activated).toBe(true);
    expect(first.body.payment.status).toBe('paid');
    expect(first.body.payment.entitlementApplied).toBe(true);
    expect(first.body.subscription).toMatchObject({
      isActive: true,
      status: 'active',
      amount: 1999,
    });
    const firstExpiry = first.body.subscription.expiryDate;

    const second = await request(ctx.app).post(
      `/api/v1/payments/pix/${created.body.paymentId}/simulate`
    );

    expect(second.status).toBe(200);
    expect(second.body.activated).toBe(false);
    expect(second.body.subscription.expiryDate).toBe(firstExpiry);

    const status = await request(ctx.app).get(
      `/api/v1/payments/pix/${created.body.paymentId}`
    );
    expect(status.body.status).toBe('paid');
  });

  it('não simula pagamento expirado (409) e marca como expired', async () => {
    const payment = await seedPayment({
      expiresAt: new Date(Date.now() - 1000),
    });

    const response = await request(ctx.app).post(
      `/api/v1/payments/pix/${payment.id}/simulate`
    );

    expect(response.status).toBe(409);
    expect(response.body.error.code).toBe('PAYMENT_EXPIRED');

    const persisted = await Payment.findById(payment.id);
    expect(persisted.status).toBe('expired');
  });

  it('status consultado também expira pagamento vencido', async () => {
    const payment = await seedPayment({
      expiresAt: new Date(Date.now() - 1000),
    });

    const response = await request(ctx.app).get(
      `/api/v1/payments/pix/${payment.id}`
    );

    expect(response.status).toBe(200);
    expect(response.body.status).toBe('expired');
  });

  it('marca pagamento como expirado quando expira após criar', async () => {
    const created = await createPix();
    await Payment.updateOne(
      { _id: created.body.paymentId },
      { $set: { expiresAt: new Date(Date.now() - 5000) } }
    );

    const response = await request(ctx.app).get(
      `/api/v1/payments/pix/${created.body.paymentId}`
    );

    expect(response.body.status).toBe('expired');
  });

  it('cria assinatura pendente ao gerar a cobrança', async () => {
    const deviceId = 'pix-pending-subscription';
    await createPix({ deviceId });

    const validation = await request(ctx.app)
      .post('/api/v1/subscription/validate')
      .send({ deviceId });

    expect(validation.status).toBe(200);
    expect(validation.body.isActive).toBe(false);
    expect(validation.body.status).toBe('pending');
  });

  it('retorna 503 no alias /pagamento quando Stripe não está configurado', async () => {
    const response = await request(ctx.app)
      .post('/pagamento')
      .send({ valor: 499, deviceId: DEVICE_A });

    expect(response.status).toBe(503);
    expect(response.body.error.code).toBe('STRIPE_NOT_CONFIGURED');
  });

  it('provider real sem credenciais falha com 503 antes de persistir', async () => {
    const env = buildEnv({
      PIX_PROVIDER: 'mercadopago',
      MERCADOPAGO_ACCESS_TOKEN: '',
    });

    await expect(
      createPixPayment({ deviceId: DEVICE_A, amountCents: 499, env })
    ).rejects.toMatchObject({
      status: 503,
      code: 'PIX_PROVIDER_NOT_CONFIGURED',
    });
  });

  it('mantém o alias legado POST /pix/gerar funcionando', async () => {
    const response = await request(ctx.app)
      .post('/pix/gerar')
      .send({ valor: 499, deviceId: DEVICE_A });

    expect(response.status).toBe(201);
    expect(response.body.status).toBe('pending');
    expect(inspectPixPayload(response.body.copiaECola).valid).toBe(true);

    const status = await request(ctx.app).get(`/pix/${response.body.paymentId}`);
    expect(status.status).toBe(200);
    expect(status.body.status).toBe('pending');
  });
});
