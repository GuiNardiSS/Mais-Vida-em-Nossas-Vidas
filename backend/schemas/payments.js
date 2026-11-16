import { z } from 'zod';

import {
  amountFields,
  deviceIdSchema,
  deviceInfoSchema,
  objectIdSchema,
} from './common.js';

/** POST /api/v1/payments/pix (e alias /pix/gerar). */
export const createPixSchema = z
  .object({
    deviceId: deviceIdSchema,
    ...amountFields,
    deviceInfo: deviceInfoSchema,
  })
  .refine((value) => value.amount !== undefined || value.valor !== undefined, {
    message: 'Informe amount (centavos) ou valor (compatibilidade).',
    path: ['amount'],
  });

/** GET /api/v1/payments/pix/:id */
export const getPixSchema = {
  params: z.object({ id: objectIdSchema }),
  query: z
    .object({
      deviceId: deviceIdSchema.optional(),
    })
    .default({}),
};

/** POST /api/v1/payments/pix/:id/simulate (apenas DEMO_MODE). */
export const simulatePixSchema = {
  params: z.object({ id: objectIdSchema }),
  body: z
    .object({
      deviceId: deviceIdSchema.optional(),
    })
    .passthrough()
    .optional(),
};

/** POST /api/v1/payments/stripe/intent (e alias /pagamento). */
export const createStripeIntentSchema = z
  .object({
    deviceId: deviceIdSchema,
    ...amountFields,
    deviceInfo: deviceInfoSchema,
  })
  .refine((value) => value.amount !== undefined || value.valor !== undefined, {
    message: 'Informe amount (centavos) ou valor (compatibilidade).',
    path: ['amount'],
  });
