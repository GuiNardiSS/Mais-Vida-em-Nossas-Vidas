import Subscription from '../models/Subscription.js';
import { ApiError } from '../utils/ApiError.js';

const maskDeviceId = (deviceId) =>
  typeof deviceId === 'string'
    ? `${deviceId.slice(0, Math.min(8, deviceId.length))}...`
    : undefined;

/** Contrato de leitura mantido compatível com o app antigo. */
export function toSubscriptionView(subscription) {
  if (!subscription) return null;

  return {
    isActive: subscription.isActive(),
    status: subscription.status,
    startDate: subscription.startDate,
    expiryDate: subscription.expiryDate,
    daysRemaining: subscription.daysRemaining(),
    paymentMethod: subscription.paymentMethod,
    amount: subscription.amount,
    createdAt: subscription.createdAt,
  };
}

/** Marca expiração de forma preguiçosa (sem job externo). */
export async function expireIfNeeded(subscription) {
  if (
    subscription?.status === 'active' &&
    subscription.expiryDate?.getTime() <= Date.now()
  ) {
    subscription.status = 'expired';
    await subscription.save();
  }
  return subscription;
}

/** POST /subscription/validate (contrato antigo preservado). */
export async function validateSubscription(deviceId) {
  const subscription = await Subscription.findOne({ deviceId });

  if (!subscription) {
    return {
      isActive: false,
      status: 'free',
      message: 'Nenhuma assinatura encontrada.',
      expiryDate: null,
      daysRemaining: 0,
    };
  }

  await expireIfNeeded(subscription);
  const active = subscription.isActive();

  return {
    isActive: active,
    status: active ? 'active' : subscription.status,
    expiryDate: subscription.expiryDate,
    daysRemaining: active ? subscription.daysRemaining() : 0,
  };
}

/** GET /subscription/info — null quando não existe (controller responde 404). */
export async function getSubscriptionInfo(deviceId) {
  const subscription = await Subscription.findOne({ deviceId });
  if (!subscription) return null;

  await expireIfNeeded(subscription);

  return {
    ...toSubscriptionView(subscription),
    deviceId: maskDeviceId(subscription.deviceId),
  };
}

/** POST /subscription/cancel — idempotente. */
export async function cancelSubscription(deviceId, reason) {
  const subscription = await Subscription.findOne({ deviceId });
  if (!subscription) {
    throw ApiError.notFound(
      'SUBSCRIPTION_NOT_FOUND',
      'Assinatura não encontrada para este dispositivo.'
    );
  }

  const alreadyCancelled = subscription.status === 'cancelled';
  if (!alreadyCancelled) {
    await subscription.cancel(reason);
  }

  return {
    success: true,
    alreadyCancelled,
    message: alreadyCancelled
      ? 'Assinatura já estava cancelada.'
      : 'Assinatura cancelada com sucesso.',
    subscription: toSubscriptionView(subscription),
  };
}

export default {
  toSubscriptionView,
  expireIfNeeded,
  validateSubscription,
  getSubscriptionInfo,
  cancelSubscription,
};
