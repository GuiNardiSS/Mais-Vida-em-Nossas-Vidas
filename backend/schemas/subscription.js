import { z } from 'zod';

import {
  deviceIdSchema,
  deviceInfoSchema,
  objectIdSchema,
} from './common.js';

/**
 * POST /api/v1/subscription/activate
 *
 * A ativação exige `paymentId` de um pagamento comprovadamente pago.
 * `transactionId` continua no schema apenas para responder com um erro
 * explícito — ele NUNCA ativa uma assinatura sozinho.
 */
export const activateSubscriptionSchema = z
  .object({
    deviceId: deviceIdSchema,
    paymentId: objectIdSchema.optional(),
    demoToken: z.string().trim().min(8).max(256).optional(),
    transactionId: z.string().trim().max(128).optional(),
    paymentMethod: z.enum(['pix', 'card']).optional(),
    deviceInfo: deviceInfoSchema,
  })
  .passthrough();

/** POST /api/v1/subscription/validate */
export const validateSubscriptionSchema = z.object({
  deviceId: deviceIdSchema,
});

/** GET /api/v1/subscription/info?deviceId= */
export const subscriptionInfoSchema = {
  query: z.object({
    deviceId: deviceIdSchema,
  }),
};

/** POST /api/v1/subscription/cancel */
export const cancelSubscriptionSchema = z.object({
  deviceId: deviceIdSchema,
  reason: z.string().trim().max(200).optional(),
});

/** POST /api/v1/webhooks/stripe (payload cru; validação mínima). */
export const stripeWebhookSchema = z
  .object({
    id: z.string().optional(),
    type: z.string().min(1),
    data: z.object({
      object: z.record(z.string(), z.any()),
    }),
  })
  .passthrough();
