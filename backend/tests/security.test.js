import { jest } from '@jest/globals';
import request from 'supertest';
import YAML from 'yaml';

import { loadEnv } from '../config/env.js';
import { createAuth } from '../middleware/auth.js';
import { startTestContext } from './helpers/context.js';

describe('Segurança, erros padronizados e configuração', () => {
  let ctx;

  beforeAll(async () => {
    ctx = await startTestContext();
  });

  afterAll(async () => {
    await ctx.close();
  });

  it('responde 404 padronizado com requestId', async () => {
    const response = await request(ctx.app).get('/rota-inexistente');

    expect(response.status).toBe(404);
    expect(response.body.error).toMatchObject({
      code: 'NOT_FOUND',
      message: 'Rota não encontrada.',
    });
    expect(response.body.error.requestId).toBeTruthy();
    expect(response.headers['x-request-id']).toBe(response.body.error.requestId);
  });

  it('propaga X-Request-Id válido e gera um novo para valor inválido', async () => {
    const provided = 'req-test-12345678';
    const response = await request(ctx.app)
      .get('/rota-inexistente')
      .set('X-Request-Id', provided);

    expect(response.headers['x-request-id']).toBe(provided);
    expect(response.body.error.requestId).toBe(provided);

    const invalid = await request(ctx.app)
      .get('/rota-inexistente')
      .set('X-Request-Id', 'abc');
    expect(invalid.headers['x-request-id']).not.toBe('abc');
    expect(invalid.headers['x-request-id']).toMatch(
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
    );
  });

  it('retorna 400 INVALID_JSON para corpo malformado', async () => {
    const response = await request(ctx.app)
      .post('/api/v1/payments/pix')
      .set('Content-Type', 'application/json')
      .send('{"deviceId": ');

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('INVALID_JSON');
  });

  it('detalha erros de validação por campo', async () => {
    const response = await request(ctx.app)
      .post('/api/v1/subscription/validate')
      .send({});

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
    expect(response.body.error.details).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          source: 'body',
          path: 'body.deviceId',
        }),
      ])
    );
  });

  it('aplica headers do Helmet', async () => {
    const response = await request(ctx.app).get('/api/v1');

    expect(response.headers['x-content-type-options']).toBe('nosniff');
    expect(response.headers['x-frame-options']).toBe('SAMEORIGIN');
    expect(response.headers['x-powered-by']).toBeUndefined();
    expect(response.headers['content-security-policy']).toBeTruthy();
  });

  it('aplica CORS por allowlist', async () => {
    const allowed = await request(ctx.app)
      .get('/api/v1')
      .set('Origin', 'http://allowed.example');

    expect(allowed.headers['access-control-allow-origin']).toBe(
      'http://allowed.example'
    );

    const blocked = await request(ctx.app)
      .get('/api/v1')
      .set('Origin', 'http://evil.example');

    expect(blocked.headers['access-control-allow-origin']).toBeUndefined();
  });

  it('serve Swagger UI e o openapi.yaml', async () => {
    const docs = await request(ctx.app).get('/docs/');
    expect(docs.status).toBe(200);
    expect(docs.text).toContain('swagger-ui');

    const spec = await request(ctx.app).get('/openapi.yaml');
    expect(spec.status).toBe(200);

    const document = YAML.parse(spec.text);
    expect(document.openapi).toMatch(/^3\./);
    expect(document.paths['/api/v1/payments/pix']).toBeTruthy();
    expect(document.paths['/api/v1/webhooks/stripe']).toBeTruthy();
    expect(document.paths['/pix/gerar'].post.deprecated).toBe(true);
  });

  it('expõe health sem vazar detalhes internos', async () => {
    const response = await request(ctx.app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      status: 'ok',
      database: 'connected',
    });

    const v1 = await request(ctx.app).get('/api/v1/health');
    expect(v1.status).toBe(200);
  });

  it('JWT: requireAuth rejeita ausência e token inválido', () => {
    const auth = createAuth({ jwtSecret: 'unit-test-secret' });

    const noTokenNext = jest.fn();
    auth.requireAuth({ get: () => undefined }, {}, noTokenNext);
    expect(noTokenNext.mock.calls[0][0].status).toBe(401);
    expect(noTokenNext.mock.calls[0][0].code).toBe('NO_TOKEN');

    const badTokenNext = jest.fn();
    auth.requireAuth({ get: () => 'Bearer token-invalido' }, {}, badTokenNext);
    expect(badTokenNext.mock.calls[0][0].status).toBe(401);
    expect(badTokenNext.mock.calls[0][0].code).toBe('INVALID_TOKEN');

    const token = auth.generateDeviceToken('device-jwt');
    const okNext = jest.fn();
    const req = { get: () => `Bearer ${token}` };
    auth.requireAuth(req, {}, okNext);
    expect(okNext).toHaveBeenCalledWith();
    expect(req.deviceId).toBe('device-jwt');
  });

  it('não bloqueia info quando token opcional é inválido', async () => {
    const response = await request(ctx.app)
      .get('/api/v1/subscription/info')
      .query({ deviceId: 'device-token-invalido' })
      .set('Authorization', 'Bearer token-invalido');

    expect(response.status).toBe(404);
    expect(response.body.error.code).toBe('SUBSCRIPTION_NOT_FOUND');
  });
});

describe('Validação de ambiente (config/env)', () => {
  it('exige JWT_SECRET fora de development', () => {
    expect(() => loadEnv({ NODE_ENV: 'production' })).toThrow(/JWT_SECRET/);
    expect(() => loadEnv({ NODE_ENV: 'test' })).toThrow(/JWT_SECRET/);
  });

  it('exige segredo forte em produção', () => {
    expect(() =>
      loadEnv({ NODE_ENV: 'production', JWT_SECRET: 'curto' })
    ).toThrow(/16 caracteres/);
  });

  it('permite fallback apenas em development', () => {
    const env = loadEnv({ NODE_ENV: 'development' });
    expect(env.JWT_SECRET).toBeTruthy();
    expect(env.JWT_SECRET_IS_FALLBACK).toBe(true);
  });

  it('exige DEMO_ACTIVATION_TOKEN em produção com DEMO_MODE', () => {
    expect(() =>
      loadEnv({
        NODE_ENV: 'production',
        JWT_SECRET: 'a-very-strong-production-secret',
        DEMO_MODE: 'true',
      })
    ).toThrow(/DEMO_ACTIVATION_TOKEN/);
  });

  it('normaliza booleanos e listas de CORS', () => {
    const env = loadEnv({
      NODE_ENV: 'test',
      JWT_SECRET: 'test-secret-with-enough-length',
      DEMO_MODE: 'true',
      CORS_ORIGIN: 'http://a.example, http://b.example',
    });

    expect(env.DEMO_MODE).toBe(true);
    expect(env.DEMO_ACTIVATION_TOKEN).toBe('demo-activation-token');
    expect(env.CORS_ORIGIN).toEqual(['http://a.example', 'http://b.example']);
  });

  it('rejeita PIX_PROVIDER desconhecido', () => {
    expect(() =>
      loadEnv({
        NODE_ENV: 'test',
        JWT_SECRET: 'test-secret-with-enough-length',
        PIX_PROVIDER: 'invalido',
      })
    ).toThrow(/PIX_PROVIDER/);
  });
});
