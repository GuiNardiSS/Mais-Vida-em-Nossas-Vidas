import jwt from 'jsonwebtoken';

import { ApiError } from '../utils/ApiError.js';

const extractBearerToken = (req) => {
  const header = req.get('authorization') || '';
  const [scheme, token] = header.split(' ');
  return scheme?.toLowerCase() === 'bearer' && token ? token : null;
};

/**
 * Fábrica de utilitários de autenticação por device.
 * O token carrega apenas o deviceId (não há senha/login).
 */
export function createAuth({ jwtSecret, expiresIn = '30d' }) {
  if (!jwtSecret) {
    throw new Error('jwtSecret é obrigatório para createAuth().');
  }

  const generateDeviceToken = (deviceId) =>
    jwt.sign({ deviceId, type: 'device' }, jwtSecret, { expiresIn });

  /** Valida o token se presente, mas nunca bloqueia a requisição. */
  const optionalAuth = (req, res, next) => {
    const token = extractBearerToken(req);
    if (!token) return next();

    try {
      const decoded = jwt.verify(token, jwtSecret);
      req.deviceId = decoded.deviceId;
      req.tokenValid = true;
    } catch {
      req.tokenValid = false;
    }

    return next();
  };

  /** Exige token válido. */
  const requireAuth = (req, res, next) => {
    const token = extractBearerToken(req);
    if (!token) {
      return next(
        ApiError.unauthorized('NO_TOKEN', 'Token de autenticação não fornecido.')
      );
    }

    try {
      const decoded = jwt.verify(token, jwtSecret);
      req.deviceId = decoded.deviceId;
      return next();
    } catch {
      return next(
        ApiError.unauthorized('INVALID_TOKEN', 'Token inválido ou expirado.')
      );
    }
  };

  return { generateDeviceToken, optionalAuth, requireAuth };
}

export default createAuth;
