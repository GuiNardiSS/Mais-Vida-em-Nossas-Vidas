import { ApiError } from '../utils/ApiError.js';

/**
 * Middleware de validação com Zod.
 *
 * Uso: validate({ body: schema, query: schema, params: schema })
 * Substitui req.body/query/params pelo valor parseado (tipos normalizados).
 */
export function validate(schemas) {
  return (req, res, next) => {
    const details = [];

    for (const [source, schema] of Object.entries(schemas)) {
      if (!schema) continue;

      const result = schema.safeParse(req[source]);
      if (!result.success) {
        details.push(
          ...result.error.issues.map((issue) => ({
            source,
            path: [source, ...issue.path].filter(Boolean).join('.'),
            message: issue.message,
            code: issue.code,
          }))
        );
        continue;
      }

      // req.query é um getter no Express 4; defineProperty mantém compatibilidade.
      Object.defineProperty(req, source, {
        value: result.data,
        writable: true,
        configurable: true,
        enumerable: true,
      });
    }

    if (details.length > 0) {
      return next(
        ApiError.badRequest('VALIDATION_ERROR', 'Dados de entrada inválidos.', details)
      );
    }

    return next();
  };
}

export default validate;
