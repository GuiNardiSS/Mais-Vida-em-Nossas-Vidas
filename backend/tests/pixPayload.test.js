import { crc16 } from '../utils/crc16.js';
import {
  buildPixPayload,
  inspectPixPayload,
  parsePixPayload,
  sanitizePixText,
  sanitizeTxid,
} from '../services/pixPayload.js';

describe('CRC16', () => {
  it('confere o vetor de teste CCITT-FALSE', () => {
    expect(crc16('123456789')).toBe('29B1');
  });
});

describe('BR Code PIX (EMV)', () => {
  const build = (overrides = {}) =>
    buildPixPayload({
      pixKey: 'demo@maisvida.app',
      merchantName: 'Mais Vida',
      merchantCity: 'Sao Paulo',
      amountCents: 499,
      txid: 'abc123XYZ',
      ...overrides,
    });

  it('gera payload válido com campos e CRC corretos', () => {
    const payload = build();
    const inspection = inspectPixPayload(payload);

    expect(inspection.valid).toBe(true);
    expect(inspection.tags['00']).toBe('01');
    expect(inspection.tags['52']).toBe('0000');
    expect(inspection.tags['53']).toBe('986');
    expect(inspection.tags['54']).toBe('4.99');
    expect(inspection.tags['58']).toBe('BR');
    expect(inspection.tags['59']).toBe('MAIS VIDA');
    expect(inspection.tags['60']).toBe('SAO PAULO');
    expect(parsePixPayload(inspection.tags['62'])['05']).toBe('abc123XYZ');

    // CRC é recalculado sobre tudo, incluindo a tag 6304.
    const body = payload.slice(0, -4);
    expect(crc16(body)).toBe(payload.slice(-4));
  });

  it('normaliza acentos, caracteres especiais e tamanhos', () => {
    expect(sanitizePixText('João da Silva & Cia', 25)).toBe('JOAO DA SILVA CIA');
    expect(sanitizePixText('a'.repeat(40), 25)).toHaveLength(25);
    expect(sanitizeTxid('abc-123!@#')).toBe('abc123');
    expect(sanitizeTxid('')).toBe('***');
    expect(sanitizeTxid('x'.repeat(40))).toHaveLength(25);
  });

  it('usa valores default para nome/cidade vazios', () => {
    const payload = build({ merchantName: '', merchantCity: '' });
    const inspection = inspectPixPayload(payload);

    expect(inspection.tags['59']).toBe('MAIS VIDA');
    expect(inspection.tags['60']).toBe('SAO PAULO');
  });

  it('detecta CRC corrompido', () => {
    const payload = build();
    const corrupted = `${payload.slice(0, -4)}0000`;

    expect(inspectPixPayload(corrupted)).toMatchObject({
      valid: false,
      reason: 'CRC16 não confere',
    });
  });

  it('detecta payload truncado', () => {
    const payload = build();
    expect(inspectPixPayload(payload.slice(0, 20)).valid).toBe(false);
    expect(inspectPixPayload(null).valid).toBe(false);
  });

  it('rejeita valores inválidos na geração', () => {
    expect(() => build({ amountCents: 0 })).toThrow(/inteiro positivo/);
    expect(() => build({ amountCents: 10.5 })).toThrow(/inteiro positivo/);
    expect(() => build({ pixKey: '' })).toThrow(/pixKey/);
  });
});
