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
      const durationMs = Number(process.hrtime.bigint() - req.startedAt) / 1_000_000;
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

export default requestContext;
