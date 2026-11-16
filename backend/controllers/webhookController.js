import { stripeWebhookSchema } from '../schemas/subscription.js';
import {
  constructStripeEvent,
  processStripeEvent,
} from '../services/stripeService.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

/**
 * POST /api/v1/webhooks/stripe
 *
 * Requer o corpo cru (Buffer) para validar a assinatura do Stripe. A rota é
 * montada antes do express.json() no app.
 */
export const stripeWebhook = asyncHandler(async (req, res) => {
  const env = req.app.locals.env;
  const logger = req.app.locals.logger;

  const rawBody = Buffer.isBuffer(req.body)
    ? req.body
    : Buffer.from(typeof req.body === 'string' ? req.body : JSON.stringify(req.body || {}));

  if (!env.STRIPE_WEBHOOK_SECRET && env.NODE_ENV !== 'production') {
    logger.warn('webhook stripe sem STRIPE_WEBHOOK_SECRET (somente ambiente de teste)', {
      requestId: req.id,
    });
  }

  const event = constructStripeEvent({
    rawBody,
    signature: req.get('stripe-signature'),
    env,
  });

  const parsed = stripeWebhookSchema.safeParse(event);
  if (!parsed.success) {
    throw ApiError.badRequest(
      'WEBHOOK_INVALID',
      'Evento de webhook inválido.',
      parsed.error.issues.map((issue) => ({
        path: issue.path.join('.'),
        message: issue.message,
      }))
    );
  }

  const result = await processStripeEvent({ event: parsed.data, env });

  logger.info('webhook stripe processado', {
    requestId: req.id,
    eventId: parsed.data.id,
    type: parsed.data.type,
    ...result,
  });

  res.json(result);
});

export default stripeWebhook;
