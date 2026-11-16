import { Router } from 'express';

import {
  createPix,
  createStripePaymentIntent,
  getPix,
  simulatePix,
} from '../controllers/paymentController.js';
import { requireDatabase } from '../middleware/requireDatabase.js';
import { validate } from '../middleware/validate.js';
import {
  createPixSchema,
  createStripeIntentSchema,
  getPixSchema,
  simulatePixSchema,
} from '../schemas/payments.js';

/**
 * Handlers compartilhados entre /api/v1 e os aliases legados.
 * Garante que as duas superfícies usem exatamente a mesma lógica.
 */
export function createPaymentHandlers({ limiters }) {
  return {
    createPix: [
      limiters.payment,
      validate({ body: createPixSchema }),
      createPix,
    ],
    getPix: [validate(getPixSchema), getPix],
    simulatePix: [
      limiters.payment,
      validate(simulatePixSchema),
      simulatePix,
    ],
    createStripeIntent: [
      limiters.payment,
      validate({ body: createStripeIntentSchema }),
      createStripePaymentIntent,
    ],
  };
}

export function createPaymentRoutes({ limiters }) {
  const router = Router();
  const handlers = createPaymentHandlers({ limiters });

  router.use(requireDatabase);
  router.post('/pix', ...handlers.createPix);
  router.get('/pix/:id', ...handlers.getPix);
  router.post('/pix/:id/simulate', ...handlers.simulatePix);
  router.post('/stripe/intent', ...handlers.createStripeIntent);

  return router;
}

export default createPaymentRoutes;
