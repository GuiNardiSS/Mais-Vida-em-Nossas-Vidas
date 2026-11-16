import { Router } from 'express';
import { z } from 'zod';

import { info } from '../controllers/subscriptionController.js';
import { validate } from '../middleware/validate.js';
import { deviceIdSchema } from '../schemas/common.js';
import { createPaymentHandlers } from './payments.js';
import { createSubscriptionHandlers } from './subscription.js';

const infoByPathParam = (auth) => [
  auth.optionalAuth,
  validate({ params: z.object({ deviceId: deviceIdSchema }) }),
  (req, res, next) => {
    Object.defineProperty(req, 'query', {
      value: { deviceId: req.params.deviceId },
      writable: true,
      configurable: true,
      enumerable: true,
    });
    return info(req, res, next);
  },
];

/**
 * Aliases das rotas antigas, mantidos sem duplicar lógica:
 * os mesmos handlers (controllers + validação + rate limit) são remontados.
 *
 * Superfícies antigas:
 * - POST /pix/gerar
 * - POST /pagamento, POST /pagamento/criar-intent
 * - POST /subscription/{activate,validate,cancel}, GET /subscription/info
 */
export function createLegacyRoutes({ limiters, auth }) {
  const router = Router();
  const payment = createPaymentHandlers({ limiters });
  const subscription = createSubscriptionHandlers({ limiters, auth });

  router.post('/pix/gerar', ...payment.createPix);
  router.get('/pix/:id', ...payment.getPix);
  router.post('/pix/:id/simulate', ...payment.simulatePix);

  router.post('/pagamento', ...payment.createStripeIntent);
  router.post('/pagamento/criar-intent', ...payment.createStripeIntent);

  router.post('/subscription/activate', ...subscription.activate);
  router.post('/subscription/validate', ...subscription.validate);
  router.get('/subscription/info', ...subscription.info);
  router.get('/subscription/info/:deviceId', ...infoByPathParam(auth));
  router.post('/subscription/cancel', ...subscription.cancel);

  return router;
}

export default createLegacyRoutes;
