import { z } from 'zod';

const DEV_JWT_SECRET = 'dev-only-secret-change-me-before-production';
const DEV_DEMO_TOKEN = 'demo-activation-token';

const emptyToUndefined = (value) =>
  typeof value === 'string' && value.trim() === '' ? undefined : value;

const optionalString = z.preprocess(emptyToUndefined, z.string().trim().optional());

const booleanFromEnv = (defaultValue) =>
  z
    .preprocess((value) => {
      if (value === undefined || value === '') return defaultValue;
      if (typeof value === 'boolean') return value;
      return ['1', 'true', 'yes', 'on'].includes(String(value).trim().toLowerCase());
    }, z.boolean());

const intFromEnv = (defaultValue, min, max) =>
  z.preprocess(
    (value) => (value === undefined || value === '' ? defaultValue : Number(value)),
    z.number().int().min(min).max(max)
  );

const csvFromEnv = (defaultValue) =>
  z
    .string()
    .optional()
    .transform((value) => {
      const source = value === undefined ? defaultValue : value;
      return source
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean);
    });

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: intFromEnv(3000, 1, 65535),
  MONGODB_URI: z.string().min(1).default('mongodb://127.0.0.1:27017/maisvidaapp'),
  TRUST_PROXY: booleanFromEnv(false),

  JWT_SECRET: optionalString,
  JWT_EXPIRES_IN: z.string().default('30d'),

  CORS_ORIGIN: csvFromEnv('*'),

  DEMO_MODE: booleanFromEnv(false),
  DEMO_ACTIVATION_TOKEN: optionalString,

  PIX_PROVIDER: z.enum(['mock', 'mercadopago', 'asaas', 'efi']).default('mock'),
  PIX_KEY: z.string().min(1).default('demo@maisvida.app'),
  PIX_RECEIVER_NAME: z.string().min(1).default('MAIS VIDA'),
  PIX_RECEIVER_CITY: z.string().min(1).default('SAO PAULO'),
  PIX_EXPIRATION_SECONDS: intFromEnv(3600, 60, 86400),

  MERCADOPAGO_ACCESS_TOKEN: optionalString,
  ASAAS_API_KEY: optionalString,
  ASAAS_CUSTOMER_ID: optionalString,
  EFI_CLIENT_ID: optionalString,
  EFI_CLIENT_SECRET: optionalString,

  STRIPE_SECRET_KEY: optionalString,
  STRIPE_WEBHOOK_SECRET: optionalString,

  PLAN_AMOUNT_CENTS: intFromEnv(499, 1, 10000000),
  PLAN_DAYS: intFromEnv(30, 1, 3650),

  RATE_LIMIT_GENERAL_WINDOW_MS: intFromEnv(60_000, 1000, 86_400_000),
  RATE_LIMIT_GENERAL_MAX: intFromEnv(30, 1, 1_000_000),
  RATE_LIMIT_PAYMENT_WINDOW_MS: intFromEnv(15 * 60_000, 1000, 86_400_000),
  RATE_LIMIT_PAYMENT_MAX: intFromEnv(5, 1, 1_000_000),
  RATE_LIMIT_VALIDATION_WINDOW_MS: intFromEnv(60_000, 1000, 86_400_000),
  RATE_LIMIT_VALIDATION_MAX: intFromEnv(10, 1, 1_000_000),

  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error', 'silent']).optional(),
  DOCS_ENABLED: booleanFromEnv(true),
});

/**
 * Valida e normaliza as variáveis de ambiente.
 *
 * Regras de segurança:
 * - JWT_SECRET é obrigatório fora de development (test/production).
 * - Em produção o segredo precisa ter ao menos 16 caracteres.
 * - DEMO_MODE em produção exige DEMO_ACTIVATION_TOKEN explícito.
 */
export function loadEnv(raw = process.env) {
  const parsed = envSchema.safeParse(raw);

  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((issue) => `${issue.path.join('.') || 'env'}: ${issue.message}`)
      .join('\n');
    throw new Error(`Configuração de ambiente inválida:\n${issues}`);
  }

  const env = { ...parsed.data };
  env.CORS_ORIGIN = env.CORS_ORIGIN.length > 0 ? env.CORS_ORIGIN : ['*'];

  if (!env.JWT_SECRET) {
    if (env.NODE_ENV === 'development') {
      env.JWT_SECRET = DEV_JWT_SECRET;
      env.JWT_SECRET_IS_FALLBACK = true;
    } else {
      throw new Error(
        'JWT_SECRET é obrigatório quando NODE_ENV não é "development". Defina um segredo forte no ambiente.'
      );
    }
  } else {
    env.JWT_SECRET_IS_FALLBACK = false;
  }

  if (env.NODE_ENV === 'production' && env.JWT_SECRET.length < 16) {
    throw new Error('JWT_SECRET deve ter ao menos 16 caracteres em produção.');
  }

  if (env.DEMO_MODE && !env.DEMO_ACTIVATION_TOKEN) {
    if (env.NODE_ENV === 'production') {
      throw new Error(
        'DEMO_ACTIVATION_TOKEN é obrigatório em produção quando DEMO_MODE=true.'
      );
    }
    env.DEMO_ACTIVATION_TOKEN = DEV_DEMO_TOKEN;
  }

  if (!env.LOG_LEVEL) {
    env.LOG_LEVEL = env.NODE_ENV === 'test' ? 'silent' : 'info';
  }

  return Object.freeze(env);
}

export const isProduction = (env) => env.NODE_ENV === 'production';

export default loadEnv;
