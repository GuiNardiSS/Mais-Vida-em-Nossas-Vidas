import rateLimit from 'express-rate-limit';

const handler = (message) => (req, res) => {
  res.status(429).json({
    error: {
      code: 'RATE_LIMITED',
      message,
      requestId: req.id,
    },
  });
};

const build = ({ windowMs, max, message, keyPrefix }) =>
  rateLimit({
    windowMs,
    limit: max,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    handler: handler(message),
    // Em testes cada app tem seu próprio store; o prefixo evita colisão de chaves.
    keyGenerator: (req) => `${keyPrefix}:${req.ip}`,
    validate: { xForwardedForHeader: false },
  });

/**
 * Fábrica de rate limiters. Cada instância de app recebe stores independentes,
 * o que permite testar limites baixos sem afetar os demais testes.
 */
export function createRateLimiters(env) {
  return {
    general: build({
      windowMs: env.RATE_LIMIT_GENERAL_WINDOW_MS,
      max: env.RATE_LIMIT_GENERAL_MAX,
      message: 'Limite de requisições excedido. Tente novamente em instantes.',
      keyPrefix: 'general',
    }),
    payment: build({
      windowMs: env.RATE_LIMIT_PAYMENT_WINDOW_MS,
      max: env.RATE_LIMIT_PAYMENT_MAX,
      message: 'Muitas tentativas de pagamento. Tente novamente mais tarde.',
      keyPrefix: 'payment',
    }),
    validation: build({
      windowMs: env.RATE_LIMIT_VALIDATION_WINDOW_MS,
      max: env.RATE_LIMIT_VALIDATION_MAX,
      message: 'Muitas validações de assinatura. Tente novamente em breve.',
      keyPrefix: 'validation',
    }),
    webhook: build({
      windowMs: env.RATE_LIMIT_GENERAL_WINDOW_MS,
      max: Math.max(env.RATE_LIMIT_GENERAL_MAX, 300),
      message: 'Limite de webhooks excedido.',
      keyPrefix: 'webhook',
    }),
  };
}
