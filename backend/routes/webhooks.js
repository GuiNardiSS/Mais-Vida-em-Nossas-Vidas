import express, { Router } from 'express';

import { stripeWebhook } from '../controllers/webhookController.js';

export function createWebhookRoutes({ limiters }) {
  const router = Router();

  // Corpo cru obrigatório para validar a assinatura do Stripe.
  router.post(
    '/stripe',
    limiters.webhook,
    express.raw({ type: 'application/json', limit: '1mb' }),
    stripeWebhook
  );

  return router;
}

export default createWebhookRoutes;
