/**
 * Erro de aplicação com status HTTP e código de erro estável.
 * O error handler serializa instâncias desta classe no formato
 * `{ error: { code, message, details?, requestId } }`.
 */
export class ApiError extends Error {
  constructor(status, code, message, details) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.code = code;
    this.details = details;
    this.expose = true;
    Error.captureStackTrace?.(this, ApiError);
  }

  static badRequest(code, message, details) {
    return new ApiError(400, code, message, details);
  }

  static unauthorized(code, message) {
    return new ApiError(401, code, message);
  }

  static forbidden(code, message) {
    return new ApiError(403, code, message);
  }

  static notFound(code, message) {
    return new ApiError(404, code, message);
  }

  static conflict(code, message, details) {
    return new ApiError(409, code, message, details);
  }

  static unprocessable(code, message, details) {
    return new ApiError(422, code, message, details);
  }

  static serviceUnavailable(code, message) {
    return new ApiError(503, code, message);
  }
}

export default ApiError;
