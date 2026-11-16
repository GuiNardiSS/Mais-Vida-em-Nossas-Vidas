import { isDBConnected } from '../config/database.js';
import { ApiError } from '../utils/ApiError.js';

/**
 * Retorna 503 padronizado quando o MongoDB não está disponível.
 * Evita que falhas de banco virem 500 genéricos ou comportamentos parciais.
 */
export function requireDatabase(req, res, next) {
  if (!isDBConnected()) {
    return next(
      ApiError.serviceUnavailable(
        'DB_OFFLINE',
        'Banco de dados indisponível. Tente novamente em alguns instantes.'
      )
    );
  }
  return next();
}

export default requireDatabase;
