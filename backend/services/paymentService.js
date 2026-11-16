import { randomBytes } from 'node:crypto';

import Payment from '../models/Payment.js';
import Subscription from '../models/Subscription.js';
import { ApiError } from '../utils/ApiError.js';
import { buildPixPayload } from './pixPayload.js';
import { createPixChargeAtProvider } from './pixProviders.js';
import { applyEntitlementToPayment } from './entitlementService.js';

const generateTxid = () =>
  `mv${Date.now().toString(36)}${randomBytes(5).toString('hex')}`.slice(0, 25);

const ensurePendingSubscription = async (deviceId, now) => {
  await Subscription.updateOne(
    { deviceId },
    {
      $setOnInsert: {
        deviceId,
        status: 'pending',
        paymentMethod: 'none',
        amount: 0,
        expiryDate: now,
      },
    },
    { upsert: true, setDefaultsOnInsert: true }
  );
};

/**
 * Cria uma cobrança PIX com BR Code EMV válido.
 * O provider vem da configuração do servidor (nunca do cliente) e o default
 * é `mock`, que funciona sem credenciais externas.
 */
export async function createPixPayment({ deviceId, amountCents, deviceInfo, env }) {
  const now = new Date();
  const expiresAt = new Date(now.getTime() + env.PIX_EXPIRATION_SECONDS * 1000);
  const txid = generateTxid();

  const brCode = buildPixPayload({
    pixKey: env.PIX_KEY,
    merchantName: env.PIX_RECEIVER_NAME,
    merchantCity: env.PIX_RECEIVER_CITY,
    amountCents,
    txid,
  });

  const charge = await createPixChargeAtProvider({
    brCode,
    expiresAt,
    txid,
    amountCents,
    deviceId,
    env,
  });

  const payment = await Payment.create({
    provider: charge.provider,
    method: 'pix',
    deviceId,
    amount: amountCents,
    currency: 'BRL',
    status: 'pending',
    externalId: charge.externalId,
    txid,
    brCode: charge.brCode,
    qrCodeImage: charge.qrCodeImage,
    expiresAt: charge.expiresAt || expiresAt,
    metadata: { isMock: Boolean(charge.isMock), deviceInfo },
    events: [{ type: 'created', source: 'api', at: now }],
  });

  await ensurePendingSubscription(deviceId, now);

  return payment;
}

/**
 * Transiciona pending -> paid de forma atômica e idempotente.
 */
export async function markPaymentPaid({ payment, source, paidAt = new Date() }) {
  if (!payment) {
    throw ApiError.notFound('PAYMENT_NOT_FOUND', 'Pagamento não encontrado.');
  }

  if (payment.isExpired()) {
    await Payment.updateOne(
      { _id: payment._id, status: 'pending' },
      {
        $set: { status: 'expired' },
        $push: { events: { type: 'expired', source, at: new Date() } },
      }
    );
    throw ApiError.conflict(
      'PAYMENT_EXPIRED',
      'Este pagamento expirou. Gere uma nova cobrança.'
    );
  }

  const updated = await Payment.findOneAndUpdate(
    { _id: payment._id, status: 'pending' },
    {
      $set: { status: 'paid', paidAt },
      $push: { events: { type: 'paid', source, at: paidAt } },
    },
    { new: true }
  );

  if (updated) {
    return { payment: updated, transitioned: true };
  }

  const current = await Payment.findById(payment._id);
  if (!current) {
    throw ApiError.notFound('PAYMENT_NOT_FOUND', 'Pagamento não encontrado.');
  }

  if (current.status === 'paid') {
    return { payment: current, transitioned: false };
  }

  throw ApiError.conflict(
    'PAYMENT_NOT_PENDING',
    `Pagamento não está pendente (status: ${current.status}).`,
    { status: current.status }
  );
}

/**
 * Simulação de pagamento PIX. Somente em DEMO_MODE e somente cobranças mock.
 * Nunca permite "confirmação" de cobrança de provedor real.
 */
export async function simulatePixPayment({ paymentId, deviceId, env }) {
  if (!env.DEMO_MODE) {
    throw ApiError.forbidden(
      'DEMO_MODE_DISABLED',
      'Simulação de pagamento disponível apenas com DEMO_MODE=true.'
    );
  }

  const payment = await Payment.findById(paymentId);
  if (!payment) {
    throw ApiError.notFound('PAYMENT_NOT_FOUND', 'Pagamento não encontrado.');
  }

  if (deviceId && payment.deviceId !== deviceId) {
    throw ApiError.forbidden(
      'PAYMENT_DEVICE_MISMATCH',
      'Este pagamento pertence a outro dispositivo.'
    );
  }

  if (payment.method !== 'pix' || payment.provider !== 'mock') {
    throw ApiError.conflict(
      'PAYMENT_NOT_SIMULATABLE',
      'Somente cobranças PIX mock podem ser simuladas.'
    );
  }

  const paid = await markPaymentPaid({
    payment,
    source: 'demo_simulate',
  });

  const entitlement = await applyEntitlementToPayment({
    payment: paid.payment,
    env,
    source: 'demo_simulate',
  });

  return {
    ...entitlement,
    transitioned: paid.transitioned,
  };
}

export async function findPaymentById(paymentId) {
  return Payment.findById(paymentId);
}

/** Expira pagamentos pendentes ao consultar o status. */
export async function expirePaymentIfNeeded(payment) {
  if (!payment?.isExpired()) return payment;

  await Payment.updateOne(
    { _id: payment._id, status: 'pending' },
    {
      $set: { status: 'expired' },
      $push: { events: { type: 'expired', source: 'status_check', at: new Date() } },
    }
  );
  payment.status = 'expired';
  return payment;
}

export async function findPaymentByExternalId(provider, externalId) {
  if (!externalId) return null;
  return Payment.findOne({ provider, externalId });
}

export async function markPaymentFailed({ payment, reason, source }) {
  const now = new Date();
  return Payment.findOneAndUpdate(
    { _id: payment._id, status: 'pending' },
    {
      $set: { status: 'failed', failedAt: now, 'metadata.failureReason': reason },
      $push: { events: { type: 'failed', source, at: now } },
    },
    { new: true }
  );
}

/** Formato público (inclui aliases do contrato antigo). */
export function toPaymentView(payment) {
  if (!payment) return null;

  return {
    paymentId: payment.id,
    id: payment.id,
    provider: payment.provider,
    method: payment.method,
    status: payment.status,
    amount: payment.amount,
    currency: payment.currency,
    transactionId: payment.txid || payment.externalId,
    brCode: payment.brCode,
    copiaECola: payment.brCode,
    qrCodeImage: payment.qrCodeImage,
    imagemQrCode: payment.qrCodeImage,
    expiresAt: payment.expiresAt,
    paidAt: payment.paidAt,
    entitlementApplied: Boolean(payment.entitlementApplied),
    isMock: payment.provider === 'mock',
    createdAt: payment.createdAt,
  };
}

export default {
  createPixPayment,
  markPaymentPaid,
  simulatePixPayment,
  findPaymentById,
  expirePaymentIfNeeded,
  findPaymentByExternalId,
  toPaymentView,
};
