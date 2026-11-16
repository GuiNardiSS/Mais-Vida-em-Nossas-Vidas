import axios from 'axios';

import { ApiError } from '../utils/ApiError.js';

const PROVIDER_TIMEOUT_MS = 15_000;
const MOCK_QR_PLACEHOLDER =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

const providerError = (provider, error) =>
  new ApiError(
    502,
    'PIX_PROVIDER_ERROR',
    `Falha ao comunicar com o provedor PIX (${provider}).`,
    { provider, cause: error.message }
  );

/**
 * Cobrança mock: BR Code EMV válido (CRC16) e nenhuma chamada externa.
 * O QR Code base64 é apenas um placeholder — o cliente deve renderizar o
 * `copiaECola` para obter um QR escaneável.
 */
export function createMockPixCharge({ brCode, expiresAt, txid, amountCents }) {
  return {
    provider: 'mock',
    externalId: txid,
    brCode,
    qrCodeImage: MOCK_QR_PLACEHOLDER,
    expiresAt,
    isMock: true,
    amountCents,
  };
}

async function createMercadoPagoPix({ amountCents, deviceId, env }) {
  const accessToken = env.MERCADOPAGO_ACCESS_TOKEN;
  if (!accessToken) {
    throw ApiError.serviceUnavailable(
      'PIX_PROVIDER_NOT_CONFIGURED',
      'MERCADOPAGO_ACCESS_TOKEN não configurado.'
    );
  }

  try {
    const { data } = await axios.post(
      'https://api.mercadopago.com/v1/payments',
      {
        transaction_amount: amountCents / 100,
        description: 'Assinatura Mensal - Mais Vida em Nossas Vidas',
        payment_method_id: 'pix',
        external_reference: deviceId,
        payer: { email: 'cliente@email.com' },
      },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        timeout: PROVIDER_TIMEOUT_MS,
      }
    );

    const transactionData = data?.point_of_interaction?.transaction_data;
    if (!transactionData?.qr_code) {
      throw new Error('resposta do Mercado Pago sem QR Code');
    }

    return {
      provider: 'mercadopago',
      externalId: String(data.id),
      brCode: transactionData.qr_code,
      qrCodeImage: transactionData.qr_code_base64 || null,
      expiresAt: data.date_of_expiration
        ? new Date(data.date_of_expiration)
        : undefined,
      isMock: false,
    };
  } catch (error) {
    throw providerError('mercadopago', error);
  }
}

async function createAsaasPix({ amountCents, deviceId, env }) {
  const apiKey = env.ASAAS_API_KEY;
  if (!apiKey) {
    throw ApiError.serviceUnavailable(
      'PIX_PROVIDER_NOT_CONFIGURED',
      'ASAAS_API_KEY não configurada.'
    );
  }

  try {
    const { data } = await axios.post(
      'https://www.asaas.com/api/v3/payments',
      {
        customer: env.ASAAS_CUSTOMER_ID || 'cus_000000000000',
        billingType: 'PIX',
        value: amountCents / 100,
        dueDate: new Date().toISOString().split('T')[0],
        description: 'Assinatura Mensal - Mais Vida em Nossas Vidas',
        externalReference: deviceId,
      },
      {
        headers: { access_token: apiKey, 'Content-Type': 'application/json' },
        timeout: PROVIDER_TIMEOUT_MS,
      }
    );

    const { data: qrCode } = await axios.get(
      `https://www.asaas.com/api/v3/payments/${data.id}/pixQrCode`,
      { headers: { access_token: apiKey }, timeout: PROVIDER_TIMEOUT_MS }
    );

    return {
      provider: 'asaas',
      externalId: String(data.id),
      brCode: qrCode.payload,
      qrCodeImage: qrCode.encodedImage || null,
      expiresAt: data.dueDate ? new Date(data.dueDate) : undefined,
      isMock: false,
    };
  } catch (error) {
    throw providerError('asaas', error);
  }
}

async function createEfiPix({ amountCents, deviceId, txid, env }) {
  if (!env.EFI_CLIENT_ID || !env.EFI_CLIENT_SECRET) {
    throw ApiError.serviceUnavailable(
      'PIX_PROVIDER_NOT_CONFIGURED',
      'EFI_CLIENT_ID/EFI_CLIENT_SECRET não configurados.'
    );
  }

  try {
    const { data: auth } = await axios.post(
      'https://api-pix.gerencianet.com.br/oauth/token',
      { grant_type: 'client_credentials' },
      {
        auth: { username: env.EFI_CLIENT_ID, password: env.EFI_CLIENT_SECRET },
        timeout: PROVIDER_TIMEOUT_MS,
      }
    );

    const authorization = `Bearer ${auth.access_token}`;

    const { data: charge } = await axios.put(
      `https://api-pix.gerencianet.com.br/v2/cob/${txid}`,
      {
        calendario: { expiracao: env.PIX_EXPIRATION_SECONDS },
        devedor: { nome: 'Cliente' },
        valor: { original: (amountCents / 100).toFixed(2) },
        chave: env.PIX_KEY,
        solicitacaoPagador: 'Assinatura Mensal - Mais Vida em Nossas Vidas',
        infoAdicionais: [{ nome: 'Device ID', valor: deviceId }],
      },
      {
        headers: { Authorization: authorization, 'Content-Type': 'application/json' },
        timeout: PROVIDER_TIMEOUT_MS,
      }
    );

    const { data: qrCode } = await axios.get(
      `https://api-pix.gerencianet.com.br/v2/loc/${charge.loc.id}/qrcode`,
      { headers: { Authorization: authorization }, timeout: PROVIDER_TIMEOUT_MS }
    );

    return {
      provider: 'efi',
      externalId: txid,
      brCode: charge.pixCopiaECola,
      qrCodeImage: qrCode.imagemQrcode || null,
      expiresAt: new Date(Date.now() + env.PIX_EXPIRATION_SECONDS * 1000),
      isMock: false,
    };
  } catch (error) {
    throw providerError('efi', error);
  }
}

/**
 * Cria a cobrança no provedor configurado.
 * O mock é o único caminho que funciona sem credenciais externas.
 */
export async function createPixChargeAtProvider(input) {
  switch (input.env.PIX_PROVIDER) {
    case 'mercadopago':
      return createMercadoPagoPix(input);
    case 'asaas':
      return createAsaasPix(input);
    case 'efi':
      return createEfiPix(input);
    case 'mock':
    default:
      return createMockPixCharge(input);
  }
}

export default createPixChargeAtProvider;
