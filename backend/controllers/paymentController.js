import { resolveAmount } from '../schemas/common.js';
import {
  createPixPayment,
  expirePaymentIfNeeded,
  findPaymentById,
  simulatePixPayment,
  toPaymentView,
} from '../services/paymentService.js';
import { createStripeIntent } from '../services/stripeService.js';
import { toSubscriptionView } from '../services/subscriptionService.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

/** POST /api/v1/payments/pix */
export const createPix = asyncHandler(async (req, res) => {
  const env = req.app.locals.env;
  const { deviceId, deviceInfo } = req.body;
  const amountCents = resolveAmount(req.body, env.PLAN_AMOUNT_CENTS);

  const payment = await createPixPayment({
    deviceId,
    amountCents,
    deviceInfo,
    env,
  });

  res.status(201).json(toPaymentView(payment));
});

/** GET /api/v1/payments/pix/:id */
export const getPix = asyncHandler(async (req, res) => {
  const payment = await findPaymentById(req.params.id);
  if (!payment) {
    throw ApiError.notFound('PAYMENT_NOT_FOUND', 'Pagamento não encontrado.');
  }

  if (req.query.deviceId && payment.deviceId !== req.query.deviceId) {
    throw ApiError.notFound('PAYMENT_NOT_FOUND', 'Pagamento não encontrado.');
  }

  await expirePaymentIfNeeded(payment);
  res.json(toPaymentView(payment));
});

/** POST /api/v1/payments/pix/:id/simulate */
export const simulatePix = asyncHandler(async (req, res) => {
  const env = req.app.locals.env;
  const result = await simulatePixPayment({
    paymentId: req.params.id,
    deviceId: req.body?.deviceId,
    env,
  });

  res.json({
    success: true,
    activated: result.activated,
    payment: toPaymentView(result.payment),
    subscription: toSubscriptionView(result.subscription),
  });
});

/** POST /api/v1/payments/stripe/intent */
export const createStripePaymentIntent = asyncHandler(async (req, res) => {
  const env = req.app.locals.env;
  const amountCents = resolveAmount(req.body, env.PLAN_AMOUNT_CENTS);

  const result = await createStripeIntent({
    deviceId: req.body.deviceId,
    amountCents,
    env,
  });

  res.status(201).json(result);
});
