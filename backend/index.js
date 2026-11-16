import dotenv from 'dotenv';

import { createApp } from './app.js';
import { connectDB, disconnectDB } from './config/database.js';
import { loadEnv } from './config/env.js';
import { logger } from './utils/logger.js';

dotenv.config();

async function main() {
  const env = loadEnv();
  logger.setLevel(env.LOG_LEVEL);
  const log = logger.child({ service: 'maisvida-backend', env: env.NODE_ENV });

  if (env.JWT_SECRET_IS_FALLBACK) {
    log.warn('JWT_SECRET não definido; usando segredo de desenvolvimento.');
  }
  if (env.CORS_ORIGIN.includes('*') && env.NODE_ENV === 'production') {
    log.warn('CORS_ORIGIN=* em produção. Configure uma allowlist explícita.');
  }

  try {
    await connectDB(env.MONGODB_URI, { logger: log });
  } catch (error) {
    log.error('falha ao conectar ao MongoDB', { err: error });
    if (env.NODE_ENV === 'production') {
      process.exitCode = 1;
      return;
    }
    log.warn(
      'API continuará em modo degradado; endpoints que dependem do banco responderão 503 (DB_OFFLINE).'
    );
  }

  const app = createApp({ env });

  const server = app.listen(env.PORT, () => {
    log.info('API online', {
      port: env.PORT,
      docs: env.DOCS_ENABLED ? '/docs' : 'disabled',
      pixProvider: env.PIX_PROVIDER,
      demoMode: env.DEMO_MODE,
    });
  });

  server.on('error', (error) => {
    log.error('erro no servidor HTTP', { err: error });
    process.exitCode = 1;
  });

  const shutdown = (signal) => {
    log.info('encerrando servidor', { signal });
    server.close(async () => {
      try {
        await disconnectDB({ logger: log });
      } finally {
        process.exit(0);
      }
    });

    setTimeout(() => process.exit(1), 10_000).unref();
  };

  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

main().catch((error) => {
  console.error(
    JSON.stringify({
      level: 'error',
      time: new Date().toISOString(),
      msg: 'falha ao iniciar a API',
      err: { name: error.name, message: error.message },
    })
  );
  process.exitCode = 1;
});
