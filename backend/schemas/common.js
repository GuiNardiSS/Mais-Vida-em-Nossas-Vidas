import { z } from 'zod';

export const OBJECT_ID_PATTERN = /^[a-f0-9]{24}$/i;

export const objectIdSchema = z
  .string()
  .regex(OBJECT_ID_PATTERN, 'Identificador inválido.');

export const deviceIdSchema = z
  .string()
  .trim()
  .min(4, 'deviceId deve ter ao menos 4 caracteres.')
  .max(128, 'deviceId deve ter no máximo 128 caracteres.')
  .regex(/^[^\s/\\]+$/, 'deviceId não pode conter espaços ou barras.');

export const deviceInfoSchema = z
  .object({
    platform: z.string().trim().max(64).optional(),
    model: z.string().trim().max(128).optional(),
    version: z.string().trim().max(64).optional(),
  })
  .partial()
  .optional();

/**
 * Valores monetários são sempre inteiros em centavos.
 * `valor` é aceito por compatibilidade com o contrato antigo.
 */
export const amountSchema = z.coerce
  .number({ invalid_type_error: 'amount deve ser numérico.' })
  .int('amount deve ser um inteiro em centavos.')
  .min(100, 'amount mínimo é 100 (R$ 1,00).')
  .max(1_000_000, 'amount máximo é 1000000 (R$ 10.000,00).');

export const amountFields = {
  amount: amountSchema.optional(),
  valor: amountSchema.optional(),
};

/** Resolve o valor canônico (amount > valor > padrão do plano). */
export const resolveAmount = (input, fallback) =>
  input.amount ?? input.valor ?? fallback;
