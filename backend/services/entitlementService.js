import { timingSafeEqual } from 'node:crypto';

import Subscription from '../models/Subscription.js';
import Payment from '../models/Payment.js';
import { ApiError } from '../utils/ApiError.js';

const DAY_MS = 86_400_000;

export const addDays = (date, days) => new Date(date.getTime() + days * DAY_MS);

/**
 * Ativa/renova uma assinatura de forma idempotente por pagamento.
 * A base do novo período é a maior data entre agora e a expiração atual,
 * então renovações nunca encurtam um acesso ainda válido.
 */
export async function upsertActiveSubscription({
  deviceId,
  payment,
  env,
  source,
  deviceInfo,
}) {
  const now = new Date();
  const existing = await Subscription.findOne({ deviceId });
  const base =
    existing?.status === 'active' && existing.expiryDate?.getTime() > now.getTime()
      ? existing.expiryDate
      : now;

  const set = {
    status: 'active',
    paymentMethod: payment?.method ?? 'demo',
    amount: payment?.amount ?? 0,
    transactionId: payment ? payment.externalId || payment.txid : 'demo',
    startDate:
      existing?.status === 'active' && existing.startDate
        ? existing.startDate
        : now,
    expiryDate: addDays(base, env.PLAN_DAYS),
    cancelledAt: null,
    revokedAt: null,
    revocationReason: null,
    ...(payment ? { lastPaymentId: payment._id } : {}),
    ...(deviceInfo ? { deviceInfo } : {}),
  };

  const update = {
    $set: set,
    ...(payment ? { $addToSet: { paymentIds: payment._id } } : {}),
  };

  const subscription = await Subscription.findOneAndUpdate({ deviceId }, update, {
    new: true,
    upsert: true,
    setDefaultsOnInsert: true,
  });

  return subscription;
}

/**
 * Marca o pagamento como "entitlement aplicado" de forma atômica e ativa a
 * assinatura. Duplicatas (webhook repetido, simulate repetido, activate
 * repetido) não estendem o período novamente.
 */
export async function applyEntitlementToPayment({ payment, env, source }) {
  if (!payment) throw ApiError.notFound('PAYMENT_NOT_FOUND', 'Pagamento não encontrado.');
  if (payment.status !== 'paid') {
    throw ApiError.conflict(
      'PAYMENT_NOT_PAID',
      'Somente pagamentos confirmados podem ativar a assinatura.',
      { status: payment.status }
    );
  }

  const now = new Date();
  const claimed = await Payment.findOneAndUpdate(
    { _id: payment._id, status: 'paid', entitlementApplied: { $ne: true } },
    {
      $set: { entitlementApplied: true, entitlementAppliedAt: now },
      $push: { events: { type: 'entitlement_applied', source, at: now } },
    },
    { new: true }
  );

  if (claimed) {
    const subscription = await upsertActiveSubscription({
      deviceId: claimed.deviceId,
      payment: claimed,
      env,
      source,
    });
    return { payment: claimed, subscription, activated: true };
  }

  const current = await Payment.findById(payment._id);
  if (!current) {
    throw ApiError.notFound('PAYMENT_NOT_FOUND', 'Pagamento não encontrado.');
  }

  let subscription = await Subscription.findOne({ deviceId: current.deviceId });

  // Reparo defensivo: pagamento pago e entitlement marcado, mas assinatura
  // ausente (ex.: falha entre as duas escritas).
  if (!subscription && current.status === 'paid') {
    subscription = await upsertActiveSubscription({
      deviceId: current.deviceId,
      payment: current,
      env,
      source,
    });
  }

  return { payment: current, subscription, activated: false };
}

/**
 * Ativa assinatura a partir de um paymentId comprovadamente pago.
 * Este é o único caminho de ativação via PIX/cartão (nunca transactionId solto).
 */
export async function activateFromPayment({
  deviceId,
  paymentId,
  env,
  deviceInfo,
}) {
  const payment = await Payment.findById(paymentId);

  if (!payment) {
    throw ApiError.notFound('PAYMENT_NOT_FOUND', 'Pagamento não encontrado.');
  }

  if (payment.deviceId !== deviceId) {
    throw ApiError.forbidden(
      'PAYMENT_DEVICE_MISMATCH',
      'Este pagamento pertence a outro dispositivo.'
    );
  }

  if (payment.isExpired()) {
    await Payment.updateOne(
      { _id: payment._id, status: 'pending' },
      {
        $set: { status: 'expired' },
        $push: { events: { type: 'expired', source: 'activation', at: new Date() } },
      }
    );
    throw ApiError.conflict(
      'PAYMENT_EXPIRED',
      'Este pagamento expirou. Gere uma nova cobrança.'
    );
  }

  const result = await applyEntitlementToPayment({
    payment,
    env,
    source: 'subscription_activate',
  });

  if (result.activated && deviceInfo && result.subscription) {
    result.subscription = await Subscription.findByIdAndUpdate(
      result.subscription._id,
      { $set: { deviceInfo } },
      { new: true }
    );
  }

  return result;
}

/**
 * Ativação de demonstração (sem pagamento) protegida por token.
 * Só funciona com DEMO_MODE=true e token configurado no servidor.
 */
export async function activateWithDemoToken({ deviceId, token, env, deviceInfo }) {
  if (!env.DEMO_MODE) {
    throw ApiError.forbidden(
      'DEMO_MODE_DISABLED',
      'Ativação por token de demonstração está desabilitada.'
    );
  }

  const expected = env.DEMO_ACTIVATION_TOKEN;
  const provided = token || '';
  const matches =
    typeof expected === 'string' &&
    expected.length === provided.length &&
    timingSafeEqual(Buffer.from(expected), Buffer.from(provided));

  if (!matches) {
    throw ApiError.unauthorized(
      'INVALID_DEMO_TOKEN',
      'Token de demonstração inválido.'
    );
  }

  const existing = await Subscription.findOne({ deviceId });
  if (existing?.isActive()) {
    return { activated: false, subscription: existing, payment: null };
  }

  const subscription = await upsertActiveSubscription({
    deviceId,
    payment: null,
    env,
    source: 'demo_token',
    deviceInfo,
  });

  return { activated: true, subscription, payment: null };
}

/**
 * Revoga acesso por estorno/cancelamento no provedor.
 * Só revoga se o pagamento for o último que concedeu acesso, preservando
 * renovações posteriores legítimas.
 */
export async function revokeForPayment({ payment, reason }) {
  const now = new Date();
  const updatedPayment = await Payment.findOneAndUpdate(
    { _id: payment._id, status: { $in: ['paid', 'pending'] } },
    {
      $set: { status: 'refunded', refundedAt: now, revokedAt: now },
      $push: { events: { type: 'refunded', source: 'provider', at: now } },
    },
    { new: true }
  );

  const subscription = await Subscription.findOne({ deviceId: payment.deviceId });
  let revoked = false;

  if (
    subscription &&
    payment._id &&
    String(subscription.lastPaymentId) === String(payment._id) &&
    subscription.status === 'active'
  ) {
    await subscription.revoke(reason || 'Estorno/cancelamento no provedor.');
    revoked = true;
  }

  if (revoked) {
    // Evita que um novo ciclo de cobrança reutilize o entitlement do estorno.
    await Payment.updateOne(
      { _id: payment._id },
      { $push: { events: { type: 'subscription_revoked', source: 'provider', at: now } } }
    );
  }

  return { payment: updatedPayment || payment, subscription, revoked };
}
