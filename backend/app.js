import { readFileSync } from 'node:fs';

import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yaml';

import { loadEnv } from './config/env.js';
import { isDBConnected } from './config/database.js';
import { createAuth } from './middleware/auth.js';
import { errorHandler, notFoundHandler } from './middleware/error.js';
import { createRateLimiters } from './middleware/rateLimit.js';
import { requestContext } from './middleware/requestContext.js';
import { createApiRouter } from './routes/index.js';
import { createLegacyRoutes } from './routes/legacy.js';
import { createWebhookRoutes } from './routes/webhooks.js';
import { createLogger } from './utils/logger.js';

const loadOpenApiDocument = () => {
  const source = readFileSync(new URL('./openapi.yaml', import.meta.url), 'utf8');
  return { source, document: YAML.parse(source) };
};

const buildCorsOrigin = (allowedOrigins) => (origin, callback) => {
  // Requisições server-to-server (sem Origin) são permitidas.
  if (!origin) return callback(null, true);
  if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
    return callback(null, true);
  }
  return callback(null, false);
};

/**
 * Cria a aplicação Express sem abrir porta nem conectar ao banco.
 * Facilita testes com Supertest e mantém `index.js` responsável pelo ciclo de vida.
 */
export function createApp({ env: providedEnv } = {}) {
  const env = providedEnv || loadEnv();
  const logger = createLogger({ level: env.LOG_LEVEL }).child({
    service: 'maisvida-backend',
    env: env.NODE_ENV,
  });

  const auth = createAuth({
    jwtSecret: env.JWT_SECRET,
    expiresIn: env.JWT_EXPIRES_IN,
  });
  const limiters = createRateLimiters(env);

  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', env.TRUST_PROXY ? 1 : false);

  app.locals.env = env;
  app.locals.logger = logger;
  app.locals.auth = auth;

  app.use(requestContext({ logger }));

  const apiHelmet = helmet();
  const docsHelmet = helmet({
    contentSecurityPolicy: {
      useDefaults: true,
      directives: {
        'default-src': ["'self'"],
        'script-src': ["'self'", "'unsafe-inline'"],
        'style-src': ["'self'", "'unsafe-inline'"],
        'img-src': ["'self'", 'data:'],
        'connect-src': ["'self'"],
      },
    },
  });
  app.use((req, res, next) =>
    req.path.startsWith('/docs') ? docsHelmet(req, res, next) : apiHelmet(req, res, next)
  );

  app.use(
    cors({
      origin: buildCorsOrigin(env.CORS_ORIGIN),
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'],
      exposedHeaders: ['X-Request-Id', 'RateLimit', 'RateLimit-Policy'],
      maxAge: 86_400,
    })
  );

  app.get('/health', (req, res) => {
    const db = isDBConnected();
    res.status(200).json({
      status: 'ok',
      database: db ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
    });
  });

  // Webhooks precisam do corpo cru: montar antes do express.json().
  app.use('/api/v1/webhooks', createWebhookRoutes({ limiters }));

  app.use(express.json({ limit: '100kb' }));

  if (env.DOCS_ENABLED) {
    try {
      const { source, document } = loadOpenApiDocument();
      app.get('/openapi.yaml', (req, res) => {
        res.type('application/yaml').send(source);
      });
      app.use(
        '/docs',
        swaggerUi.serve,
        swaggerUi.setup(document, {
          customSiteTitle: 'Mais Vida API',
          swaggerOptions: { persistAuthorization: true },
        })
      );
    } catch (error) {
      logger.warn('OpenAPI/Swagger desabilitado: falha ao carregar openapi.yaml', {
        err: error,
      });
    }
  }

  app.get('/', (req, res) => {
    res.json({
      name: 'mais-vida-backend',
      version: '1.0.0',
      docs: '/docs',
      api: '/api/v1',
    });
  });

  app.use(limiters.general);
  app.use('/api/v1', createApiRouter({ limiters, auth }));
  app.use('/', createLegacyRoutes({ limiters, auth }));

  app.use(notFoundHandler);
  app.use(errorHandler({ logger, env }));

  return app;
}

export default createApp;
