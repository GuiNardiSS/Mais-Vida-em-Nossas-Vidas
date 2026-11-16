import { randomUUID } from 'node:crypto';

const REQUEST_ID_PATTERN = /^[A-Za-z0-9._:-]{8,128}$/;

/**
 * Garante um request id por requisição, propaga no header e mede a duração.
 */
export function requestContext({ logger }) {
  return (req, res, next) => {
    const incoming = req.get('x-request-id');
    req.id = REQUEST_ID_PATTERN.test(incoming || '') ? incoming : randomUUID();
    req.startedAt = process.hrtime.bigint();
    res.setHeader('X-Request-Id', req.id);

    res.on('finish', () => {
      const durationMs =
        Number(process.hrtime.bigint() - req.startedAt) / 1_000_000;
      const level = res.statusCode >= 500 ? 'error' : 'info';
      logger[level]('request', {
        requestId: req.id,
        method: req.method,
        path: req.originalUrl,
        status: res.statusCode,
        durationMs: Math.round(durationMs * 100) / 100,
        ip: req.ip,
      });
    });

    next();
  };
}

/** 404 padronizado. */
export function notFoundHandler(req, res) {
  res.status(404).json({
    error: {
      code: 'NOT_FOUND',
      message: 'Rota não encontrada.',
      requestId: req.id,
    },
  });
}

/**
 * Error handler central. Toda resposta de erro segue
 * `{ error: { code, message, details?, requestId } }`.
 */
export function errorHandler({ logger, env }) {
  // eslint-disable-next-line no-unused-vars
  return (error, req, res, next) => {
    let status = error.status || 500;
    let code = error.code || 'INTERNAL_ERROR';
    let message = error.message || 'Erro interno do servidor.';
    let details = error.details;

    if (error.type === 'entity.parse.failed') {
      status = 400;
      code = 'INVALID_JSON';
      message = 'Corpo da requisição não é um JSON válido.';
    } else if (error.type === 'entity.too.large') {
      status = 413;
      code = 'PAYLOAD_TOO_LARGE';
      message = 'Corpo da requisição excede o limite permitido.';
    } else if (error.name === 'CastError') {
      status = 400;
      code = 'INVALID_IDENTIFIER';
      message = 'Identificador inválido.';
    } else if (error.name === 'ValidationError') {
      status = 400;
      code = 'VALIDATION_ERROR';
      message = 'Dados inválidos.';
      details = Object.values(error.errors || {}).map((item) => ({
        path: item.path,
        message: item.message,
      }));
    } else if (error.code === 11000) {
      status = 409;
      code = 'DUPLICATE_RESOURCE';
      message = 'Recurso já existe.';
    }

    if (status >= 500) {
      logger.error('erro não tratado', {
        requestId: req.id,
        err: error,
        method: req.method,
        path: req.originalUrl,
      });
      if (env.NODE_ENV !== 'development') {
        message = 'Erro interno do servidor.';
        details = undefined;
      } else {
        details = details ?? error.message;
      }
    } else {
      logger.warn('requisição rejeitada', {
        requestId: req.id,
        code,
        status,
        message,
        path: req.originalUrl,
      });
    }

    const body = {
      error: {
        code,
        message,
        ...(details !== undefined ? { details } : {}),
        requestId: req.id,
      },
    };

    res.status(status).json(body);
  };
}
