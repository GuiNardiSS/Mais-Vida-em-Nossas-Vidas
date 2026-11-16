import mongoose from 'mongoose';
import request from 'supertest';

import { startTestContext } from './helpers/context.js';

describe('Rate limiting', () => {
  let ctx;

  beforeAll(async () => {
    ctx = await startTestContext();
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('responde 429 padronizado ao exceder o limite geral', async () => {
    const app = ctx.buildApp({ RATE_LIMIT_GENERAL_MAX: '2' });

    expect((await request(app).get('/api/v1')).status).toBe(200);
    expect((await request(app).get('/api/v1')).status).toBe(200);

    const blocked = await request(app).get('/api/v1');

    expect(blocked.status).toBe(429);
    expect(blocked.body.error.code).toBe('RATE_LIMITED');
    expect(blocked.body.error.requestId).toBeTruthy();
  });

  it('limita criação de PIX por IP', async () => {
    const app = ctx.buildApp({ RATE_LIMIT_PAYMENT_MAX: '1' });
    const payload = { deviceId: 'rate-pix-device', amount: 499 };

    const first = await request(app).post('/api/v1/payments/pix').send(payload);
    const second = await request(app).post('/api/v1/payments/pix').send(payload);

    expect(first.status).toBe(201);
    expect(second.status).toBe(429);
    expect(second.body.error.code).toBe('RATE_LIMITED');
  });

  it('limita validações de assinatura', async () => {
    const app = ctx.buildApp({ RATE_LIMIT_VALIDATION_MAX: '2' });
    const payload = { deviceId: 'rate-validate-device' };

    const one = await request(app)
      .post('/api/v1/subscription/validate')
      .send(payload);
    const two = await request(app)
      .post('/api/v1/subscription/validate')
      .send(payload);
    const three = await request(app)
      .post('/api/v1/subscription/validate')
      .send(payload);

    expect(one.status).toBe(200);
    expect(two.status).toBe(200);
    expect(three.status).toBe(429);
  });
});

describe('Banco offline', () => {
  let ctx;

  beforeAll(async () => {
    ctx = await startTestContext();
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('responde 503 DB_OFFLINE em endpoints que dependem do banco', async () => {
    await mongoose.disconnect();

    const pix = await request(ctx.app)
      .post('/api/v1/payments/pix')
      .send({ deviceId: 'offline-device', amount: 499 });

    expect(pix.status).toBe(503);
    expect(pix.body.error.code).toBe('DB_OFFLINE');

    const info = await request(ctx.app)
      .get('/api/v1/subscription/info')
      .query({ deviceId: 'offline-device' });

    expect(info.status).toBe(503);
    expect(info.body.error.code).toBe('DB_OFFLINE');
  });
});
