import { Router } from 'express';

import {
  activateSubscription,
  cancel,
  info,
  validate as validateSubscriptionHandler,
} from '../controllers/subscriptionController.js';
import { requireDatabase } from '../middleware/requireDatabase.js';
import { validate } from '../middleware/validate.js';
import {
  activateSubscriptionSchema,
  cancelSubscriptionSchema,
  subscriptionInfoSchema,
  validateSubscriptionSchema,
} from '../schemas/subscription.js';

export function createSubscriptionHandlers({ limiters, auth }) {
  return {
    activate: [
      requireDatabase,
      limiters.payment,
      validate({ body: activateSubscriptionSchema }),
      activateSubscription,
    ],
    validate: [
      requireDatabase,
      limiters.validation,
      validate({ body: validateSubscriptionSchema }),
      validateSubscriptionHandler,
    ],
    info: [
      requireDatabase,
      auth.optionalAuth,
      validate(subscriptionInfoSchema),
      info,
    ],
    cancel: [
      requireDatabase,
      auth.optionalAuth,
      validate({ body: cancelSubscriptionSchema }),
      cancel,
    ],
  };
}

export function createSubscriptionRoutes({ limiters, auth }) {
  const router = Router();
  const handlers = createSubscriptionHandlers({ limiters, auth });

  router.post('/activate', ...handlers.activate);
  router.post('/validate', ...handlers.validate);
  router.get('/info', ...handlers.info);
  router.post('/cancel', ...handlers.cancel);

  return router;
}

export default createSubscriptionRoutes;
