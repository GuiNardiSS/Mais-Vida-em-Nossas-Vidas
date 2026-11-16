import { crc16 } from '../utils/crc16.js';

const PIX_GUI = 'br.gov.bcb.pix';

/** Monta um campo EMV: id + tamanho (2 dígitos) + valor. */
const field = (id, value) => {
  const text = String(value);
  const size = text.length;
  if (size > 99) {
    throw new Error(`Campo EMV ${id} excede 99 caracteres.`);
  }
  return `${id}${String(size).padStart(2, '0')}${text}`;
};

/**
 * Normaliza texto para o padrão EMV (ASCII, maiúsculas, sem acentos).
 */
export function sanitizePixText(value, maxLength) {
  return String(value ?? '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^A-Za-z0-9 .,-]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .toUpperCase()
    .slice(0, maxLength);
}

export function sanitizePixKey(value) {
  return String(value ?? '')
    .trim()
    .replace(/[\u0000-\u001f\u007f]/g, '')
    .slice(0, 77);
}

export function sanitizeTxid(value) {
  const cleaned = String(value ?? '')
    .replace(/[^A-Za-z0-9]/g, '')
    .slice(0, 25);
  return cleaned.length > 0 ? cleaned : '***';
}

/**
 * Gera um BR Code (PIX EMV estático) válido, com CRC16.
 *
 * @param {object} options
 * @param {string} options.pixKey chave PIX do recebedor
 * @param {string} options.merchantName nome do recebedor (até 25 chars)
 * @param {string} options.merchantCity cidade do recebedor (até 15 chars)
 * @param {number} options.amountCents valor em centavos
 * @param {string} options.txid identificador da transação (até 25 chars alfanuméricos)
 * @returns {string} payload copia-e-cola
 */
export function buildPixPayload({
  pixKey,
  merchantName,
  merchantCity,
  amountCents,
  txid,
}) {
  const key = sanitizePixKey(pixKey);
  if (!key) throw new Error('pixKey é obrigatória para gerar o BR Code.');
  if (!Number.isInteger(amountCents) || amountCents <= 0) {
    throw new Error('amountCents deve ser um inteiro positivo.');
  }

  const name = sanitizePixText(merchantName, 25) || 'MAIS VIDA';
  const city = sanitizePixText(merchantCity, 15) || 'SAO PAULO';
  const reference = sanitizeTxid(txid);

  const merchantAccount = field('00', PIX_GUI) + field('01', key);
  const amount = (amountCents / 100).toFixed(2);

  const payloadWithoutCrc =
    field('00', '01') +
    field('26', merchantAccount) +
    field('52', '0000') +
    field('53', '986') +
    field('54', amount) +
    field('58', 'BR') +
    field('59', name) +
    field('60', city) +
    field('62', field('05', reference)) +
    '6304';

  return `${payloadWithoutCrc}${crc16(payloadWithoutCrc)}`;
}

/** Lê os campos TLV de um payload EMV (somente nível raiz). */
export function parsePixPayload(payload) {
  const tags = {};
  let index = 0;

  while (index < payload.length) {
    const id = payload.slice(index, index + 2);
    const rawLength = payload.slice(index + 2, index + 4);
    const length = Number(rawLength);
    if (!/^\d{2}$/.test(rawLength) || !Number.isInteger(length)) {
      throw new Error(`Campo EMV inválido na posição ${index}.`);
    }
    const value = payload.slice(index + 4, index + 4 + length);
    if (value.length !== length) {
      throw new Error(`Campo EMV ${id} truncado.`);
    }
    tags[id] = value;
    index += 4 + length;
  }

  return tags;
}

/**
 * Valida estrutura mínima e CRC16 de um BR Code.
 * Retorna `{ valid, reason?, tags? }` para facilitar testes e diagnóstico.
 */
export function inspectPixPayload(payload) {
  if (typeof payload !== 'string' || payload.length < 20) {
    return { valid: false, reason: 'payload muito curto' };
  }

  const body = payload.slice(0, -4);
  const providedCrc = payload.slice(-4).toUpperCase();

  if (!body.endsWith('6304')) {
    return { valid: false, reason: 'tag 63 ausente' };
  }
  if (!/^[0-9A-F]{4}$/.test(providedCrc)) {
    return { valid: false, reason: 'CRC16 ausente ou inválido' };
  }
  if (crc16(body) !== providedCrc) {
    return { valid: false, reason: 'CRC16 não confere' };
  }

  let tags;
  try {
    tags = parsePixPayload(body + providedCrc);
  } catch (error) {
    return { valid: false, reason: error.message };
  }

  const required = ['00', '26', '52', '53', '54', '58', '59', '60', '62'];
  const missing = required.filter((tag) => !tags[tag]);
  if (missing.length > 0) {
    return { valid: false, reason: `tags ausentes: ${missing.join(', ')}` };
  }
  if (!tags['26'].includes(PIX_GUI)) {
    return { valid: false, reason: 'merchant account sem GUI PIX' };
  }

  return { valid: true, tags };
}

export const isValidPixPayload = (payload) => inspectPixPayload(payload).valid;

export { PIX_GUI };
