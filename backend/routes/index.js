import { Router } from 'express';

import { isDBConnected } from '../config/database.js';
import { createPaymentRoutes } from './payments.js';
import { createSubscriptionRoutes } from './subscription.js';

const packageInfo = {
  name: 'mais-vida-backend',
  version: '1.0.0',
};

export function createApiRouter({ limiters, auth }) {
  const router = Router();

  router.get('/', (req, res) => {
    res.json({
      ...packageInfo,
      status: 'ok',
      docs: '/docs',
      openapi: '/openapi.yaml',
      endpoints: {
        createPix: 'POST /api/v1/payments/pix',
        pixStatus: 'GET /api/v1/payments/pix/:id',
        simulatePix: 'POST /api/v1/payments/pix/:id/simulate (DEMO_MODE)',
        stripeIntent: 'POST /api/v1/payments/stripe/intent',
        stripeWebhook: 'POST /api/v1/webhooks/stripe',
        activate: 'POST /api/v1/subscription/activate',
        validate: 'POST /api/v1/subscription/validate',
        info: 'GET /api/v1/subscription/info?deviceId=',
        cancel: 'POST /api/v1/subscription/cancel',
      },
    });
  });

  router.get('/health', (req, res) => {
    const db = isDBConnected();
    res.status(db ? 200 : 503).json({
      status: db ? 'ok' : 'degraded',
      database: db ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString(),
      version: packageInfo.version,
    });
  });

  router.use('/payments', createPaymentRoutes({ limiters }));
  router.use('/subscription', createSubscriptionRoutes({ limiters, auth }));

  return router;
}

export default createApiRouter;
