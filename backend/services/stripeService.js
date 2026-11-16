import Stripe from 'stripe';

import Payment from '../models/Payment.js';
import { ApiError } from '../utils/ApiError.js';
import {
  applyEntitlementToPayment,
  revokeForPayment,
} from './entitlementService.js';
import {
  findPaymentByExternalId,
  markPaymentFailed,
  markPaymentPaid,
} from './paymentService.js';

const getStripeClient = (env) => {
  if (!env.STRIPE_SECRET_KEY) {
    throw ApiError.serviceUnavailable(
      'STRIPE_NOT_CONFIGURED',
      'Stripe não configurado. Defina STRIPE_SECRET_KEY para pagamentos com cartão.'
    );
  }
  return new Stripe(env.STRIPE_SECRET_KEY);
};

/**
 * Cria um PaymentIntent e registra o pagamento local.
 * O valor sempre vem do servidor/cliente validado em centavos; a ativação
 * só acontece quando o webhook assinado confirmar `payment_intent.succeeded`.
 */
export async function createStripeIntent({ deviceId, amountCents, env }) {
  const stripe = getStripeClient(env);

  const paymentIntent = await stripe.paymentIntents.create({
    amount: amountCents,
    currency: 'brl',
    automatic_payment_methods: { enabled: true },
    metadata: {
      deviceId,
      productType: 'subscription',
      planType: 'monthly',
    },
    description: 'Assinatura Mensal - Mais Vida em Nossas Vidas',
    statement_descriptor: 'Mais Vida App',
    statement_descriptor_suffix: 'Assinatura',
  });

  const payment = await Payment.create({
    provider: 'stripe',
    method: 'card',
    deviceId,
    amount: amountCents,
    currency: 'BRL',
    status: 'pending',
    externalId: paymentIntent.id,
    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
    metadata: { productType: 'subscription' },
    events: [{ type: 'created', source: 'api', at: new Date() }],
  });

  return {
    clientSecret: paymentIntent.client_secret,
    paymentIntentId: paymentIntent.id,
    paymentId: payment.id,
    amount: amountCents,
    currency: 'BRL',
  };
}

/**
 * Valida a assinatura do webhook quando há secret configurado.
 * Sem secret: somente fora de produção (documentado como modo de teste).
 */
export function constructStripeEvent({ rawBody, signature, env }) {
  const secret = env.STRIPE_WEBHOOK_SECRET;

  if (secret) {
    if (!signature) {
      throw ApiError.badRequest(
        'WEBHOOK_SIGNATURE_MISSING',
        'Header stripe-signature ausente.'
      );
    }

    const stripe = new Stripe(env.STRIPE_SECRET_KEY || 'sk_test_signature_only');
    try {
      return stripe.webhooks.constructEvent(rawBody, signature, secret);
    } catch {
      throw ApiError.badRequest(
        'WEBHOOK_SIGNATURE_INVALID',
        'Assinatura do webhook inválida.'
      );
    }
  }

  if (env.NODE_ENV === 'production') {
    throw ApiError.serviceUnavailable(
      'WEBHOOK_NOT_CONFIGURED',
      'STRIPE_WEBHOOK_SECRET é obrigatório em produção.'
    );
  }

  try {
    return JSON.parse(rawBody.toString('utf8'));
  } catch {
    throw ApiError.badRequest('INVALID_JSON', 'Payload do webhook não é JSON válido.');
  }
}

const findStripePayment = async (paymentIntentId) => {
  if (!paymentIntentId) return null;
  return findPaymentByExternalId('stripe', String(paymentIntentId));
};

/**
 * Processa eventos relevantes do Stripe. É idempotente: eventos duplicados
 * não estendem a assinatura novamente.
 */
export async function processStripeEvent({ event, env }) {
  switch (event.type) {
    case 'payment_intent.succeeded': {
      const intent = event.data.object;
      const payment = await findStripePayment(intent.id);

      if (!payment) {
        return { received: true, ignored: 'payment_not_found' };
      }

      if (!['pending', 'paid'].includes(payment.status)) {
        return { received: true, ignored: `payment_${payment.status}` };
      }

      const paid = await markPaymentPaid({
        payment,
        source: `stripe:${event.id || event.type}`,
      });
      const entitlement = await applyEntitlementToPayment({
        payment: paid.payment,
        env,
        source: 'stripe_webhook',
      });

      return {
        received: true,
        paymentId: entitlement.payment.id,
        activated: entitlement.activated,
      };
    }

    case 'payment_intent.payment_failed': {
      const intent = event.data.object;
      const payment = await findStripePayment(intent.id);
      if (!payment) return { received: true, ignored: 'payment_not_found' };

      await markPaymentFailed({
        payment,
        reason: intent.last_payment_error?.message || 'payment_failed',
        source: `stripe:${event.id || event.type}`,
      });
      return { received: true, paymentId: payment.id, failed: true };
    }

    case 'payment_intent.canceled': {
      const intent = event.data.object;
      const payment = await findStripePayment(intent.id);
      if (!payment) return { received: true, ignored: 'payment_not_found' };

      const result = await revokeForPayment({
        payment,
        reason: 'PaymentIntent cancelado no Stripe.',
      });
      return { received: true, paymentId: payment.id, revoked: result.revoked };
    }

    case 'charge.refunded': {
      const charge = event.data.object;
      // Estorno parcial não revoga o acesso automaticamente.
      if (
        charge.refunded !== true &&
        Number(charge.amount_refunded) < Number(charge.amount)
      ) {
        return { received: true, ignored: 'partial_refund' };
      }

      const payment = await findStripePayment(charge.payment_intent);
      if (!payment) return { received: true, ignored: 'payment_not_found' };

      const result = await revokeForPayment({
        payment,
        reason: 'Pagamento estornado no Stripe.',
      });
      return { received: true, paymentId: payment.id, revoked: result.revoked };
    }

    default:
      return { received: true, ignored: `unhandled_event:${event.type}` };
  }
}
