import {
  activateFromPayment,
  activateWithDemoToken,
} from '../services/entitlementService.js';
import {
  cancelSubscription,
  getSubscriptionInfo,
  validateSubscription,
} from '../services/subscriptionService.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const maskDeviceId = (deviceId) => `${deviceId.slice(0, 8)}...`;

const buildActivationResponse = ({ result, deviceId, token }) => ({
  success: true,
  activated: result.activated,
  message: result.activated
    ? 'Assinatura ativada com sucesso.'
    : 'Assinatura já estava ativa para este pagamento.',
  paymentId: result.payment?.id,
  subscription: {
    deviceId: maskDeviceId(deviceId),
    isActive: result.subscription?.isActive() ?? false,
    status: result.subscription?.status,
    expiryDate: result.subscription?.expiryDate,
    daysRemaining: result.subscription?.daysRemaining() ?? 0,
  },
  token,
});

/**
 * POST /api/v1/subscription/activate
 *
 * Aceita apenas:
 * - paymentId de pagamento pago e pertencente ao deviceId; ou
 * - demoToken válido com DEMO_MODE=true.
 * `transactionId` arbitrário é rejeitado.
 */
export const activateSubscription = asyncHandler(async (req, res) => {
  const env = req.app.locals.env;
  const { deviceId, paymentId, demoToken, transactionId, deviceInfo } = req.body;

  let result;

  if (paymentId) {
    result = await activateFromPayment({
      deviceId,
      paymentId,
      env,
      deviceInfo,
    });
  } else if (demoToken) {
    result = await activateWithDemoToken({
      deviceId,
      token: demoToken,
      env,
      deviceInfo,
    });
  } else {
    throw ApiError.badRequest(
      'PAYMENT_REQUIRED',
      transactionId
        ? 'transactionId não ativa assinatura. Envie o paymentId de um pagamento confirmado.'
        : 'paymentId é obrigatório para ativar a assinatura.'
    );
  }

  const token = req.app.locals.auth.generateDeviceToken(deviceId);
  const status = result.activated ? 201 : 200;

  res.status(status).json(buildActivationResponse({ result, deviceId, token }));
});
/** POST /api/v1/subscription/validate */
export const validate = asyncHandler(async (req, res) => {
  const result = await validateSubscription(req.body.deviceId);
  res.json(result);
});

/** GET /api/v1/subscription/info?deviceId= */
export const info = asyncHandler(async (req, res) => {
  const subscription = await getSubscriptionInfo(req.query.deviceId);
  if (!subscription) {
    throw ApiError.notFound(
      'SUBSCRIPTION_NOT_FOUND',
      'Assinatura não encontrada para este dispositivo.'
    );
  }
  res.json(subscription);
});

/** POST /api/v1/subscription/cancel */
export const cancel = asyncHandler(async (req, res) => {
  const result = await cancelSubscription(req.body.deviceId, req.body.reason);
  res.json(result);
});
