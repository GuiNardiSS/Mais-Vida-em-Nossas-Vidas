import request from 'supertest';
import Stripe from 'stripe';

import Payment from '../models/Payment.js';
import Subscription from '../models/Subscription.js';
import {
  DEVICE_A,
  seedPayment,
  startTestContext,
  uniqueExternalId,
} from './helpers/context.js';

const stripe = new Stripe('sk_test_signature_helper');

// A assinatura do webhook é gerada offline pelo SDK (generateTestHeaderString),
// então não é preciso chamar a API do Stripe nem ter credenciais reais.
const sign = (payload, secret = process.env.STRIPE_WEBHOOK_SECRET) =>
  stripe.webhooks.generateTestHeaderString({ payload, secret });

const postWebhook = (app, payload, { signature, secret } = {}) => {
  const signatureHeader =
    signature ??
    sign(payload, secret ?? process.env.STRIPE_WEBHOOK_SECRET);

  const requestBuilder = request(app)
    .post('/api/v1/webhooks/stripe')
    .set('Content-Type', 'application/json');

  if (signatureHeader) {
    requestBuilder.set('stripe-signature', signatureHeader);
  }

  return requestBuilder.send(payload);
};

const succeededEvent = (paymentIntentId, deviceId) =>
  JSON.stringify({
    id: uniqueExternalId('evt'),
    type: 'payment_intent.succeeded',
    data: {
      object: {
        id: paymentIntentId,
        object: 'payment_intent',
        amount: 499,
        metadata: { deviceId },
      },
    },
  });

describe('Webhook do Stripe - assinatura, ativação e revogação', () => {
  let ctx;

  beforeAll(async () => {
    ctx = await startTestContext();
  });

  afterAll(async () => {
    await ctx.close();
  });

  const seedStripePayment = (deviceId) =>
    seedPayment({
      provider: 'stripe',
      method: 'card',
      deviceId,
      externalId: uniqueExternalId('pi_test'),
    });

  it('rejeita assinatura inválida e mantém pagamento pendente', async () => {
    const deviceId = 'wh-invalid-device';
    const payment = await seedStripePayment(deviceId);
    const payload = succeededEvent(payment.externalId, deviceId);

    const response = await postWebhook(ctx.app, payload, {
      signature: 't=123,v1=deadbeef',
    });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('WEBHOOK_SIGNATURE_INVALID');

    const persisted = await Payment.findById(payment.id);
    expect(persisted.status).toBe('pending');
  });

  it('ativa assinatura em payment_intent.succeeded assinado', async () => {
    const deviceId = 'wh-success-device';
    const payment = await seedStripePayment(deviceId);

    const response = await postWebhook(
      ctx.app,
      succeededEvent(payment.externalId, deviceId)
    );

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      received: true,
      activated: true,
      paymentId: payment.id,
    });

    const subscription = await Subscription.findOne({ deviceId });
    expect(subscription.status).toBe('active');
    expect(subscription.isActive()).toBe(true);
    expect(subscription.paymentMethod).toBe('card');
  });

  it('é idempotente em eventos duplicados', async () => {
    const deviceId = 'wh-duplicate-device';
    const payment = await seedStripePayment(deviceId);
    const payload = succeededEvent(payment.externalId, deviceId);

    const first = await postWebhook(ctx.app, payload);
    const second = await postWebhook(ctx.app, payload);

    expect(first.body.activated).toBe(true);
    expect(second.body.activated).toBe(false);

    const subscription = await Subscription.findOne({ deviceId });
    const elapsedDays = 30 - subscription.daysRemaining();
    expect(elapsedDays).toBeLessThanOrEqual(1);
  });

  it('ignora evento de pagamento desconhecido sem erro', async () => {
    const response = await postWebhook(
      ctx.app,
      succeededEvent('pi_test_desconhecido', DEVICE_A)
    );

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      received: true,
      ignored: 'payment_not_found',
    });
  });

  it('marca pagamento como failed em payment_intent.payment_failed', async () => {
    const deviceId = 'wh-failed-device';
    const payment = await seedStripePayment(deviceId);
    const payload = JSON.stringify({
      id: uniqueExternalId('evt'),
      type: 'payment_intent.payment_failed',
      data: {
        object: {
          id: payment.externalId,
          last_payment_error: { message: 'cartão recusado' },
        },
      },
    });

    const response = await postWebhook(ctx.app, payload);

    expect(response.status).toBe(200);
    expect(response.body.failed).toBe(true);

    const persisted = await Payment.findById(payment.id);
    expect(persisted.status).toBe('failed');
  });

  it('revoga assinatura em estorno total (charge.refunded)', async () => {
    const deviceId = 'wh-refund-device';
    const payment = await seedStripePayment(deviceId);

    await postWebhook(ctx.app, succeededEvent(payment.externalId, deviceId));

    const refundPayload = JSON.stringify({
      id: uniqueExternalId('evt'),
      type: 'charge.refunded',
      data: {
        object: {
          id: uniqueExternalId('ch'),
          object: 'charge',
          payment_intent: payment.externalId,
          amount: 499,
          amount_refunded: 499,
          refunded: true,
        },
      },
    });

    const response = await postWebhook(ctx.app, refundPayload);

    expect(response.status).toBe(200);
    expect(response.body.revoked).toBe(true);

    const subscription = await Subscription.findOne({ deviceId });
    expect(subscription.status).toBe('cancelled');
    expect(subscription.revokedAt).toBeTruthy();

    const persisted = await Payment.findById(payment.id);
    expect(persisted.status).toBe('refunded');
  });

  it('não revoga em estorno parcial', async () => {
    const deviceId = 'wh-partial-refund-device';
    const payment = await seedStripePayment(deviceId);
    await postWebhook(ctx.app, succeededEvent(payment.externalId, deviceId));

    const payload = JSON.stringify({
      id: uniqueExternalId('evt'),
      type: 'charge.refunded',
      data: {
        object: {
          id: uniqueExternalId('ch'),
          object: 'charge',
          payment_intent: payment.externalId,
          amount: 499,
          amount_refunded: 100,
          refunded: false,
        },
      },
    });

    const response = await postWebhook(ctx.app, payload);
    expect(response.body).toMatchObject({
      received: true,
      ignored: 'partial_refund',
    });

    const subscription = await Subscription.findOne({ deviceId });
    expect(subscription.status).toBe('active');
  });

  it('aceita webhook sem secret apenas fora de produção (modo de teste)', async () => {
    const appWithoutSecret = ctx.buildApp({ STRIPE_WEBHOOK_SECRET: '' });
    const deviceId = 'wh-unsigned-device';
    const payment = await seedStripePayment(deviceId);

    const response = await postWebhook(
      appWithoutSecret,
      succeededEvent(payment.externalId, deviceId)
    );

    expect(response.status).toBe(200);
    expect(response.body.activated).toBe(true);
  });

  it('rejeita evento estruturalmente inválido', async () => {
    const response = await postWebhook(
      ctx.app,
      JSON.stringify({ foo: 'bar' })
    );

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('WEBHOOK_INVALID');
  });
});
