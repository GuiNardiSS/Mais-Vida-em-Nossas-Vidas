/**
 * 404 padronizado.
 */
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
 *
 * Erros operacionais (ApiError) mantêm a mensagem mesmo em 5xx; erros
 * inesperados são mascarados fora de development para não vazar stack.
 */
export function errorHandler({ logger, env }) {
  // eslint-disable-next-line no-unused-vars
  return (error, req, res, next) => {
    let status = error.status || 500;
    let code = error.code || 'INTERNAL_ERROR';
    let message = error.message || 'Erro interno do servidor.';
    let details = error.details;
    const operational = error.expose === true;

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

      if (!operational && env.NODE_ENV !== 'development') {
        message = 'Erro interno do servidor.';
        details = undefined;
      } else if (env.NODE_ENV !== 'development') {
        // Detalhes técnicos de erros operacionais (ex.: causa do provedor)
        // ficam restritos ao ambiente de desenvolvimento.
        details = undefined;
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
