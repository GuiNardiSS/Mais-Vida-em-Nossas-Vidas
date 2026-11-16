/**
 * Encapsula handlers assíncronos para que rejeições cheguem ao error handler
 * do Express (Express 4 não faz isso automaticamente).
 */
export const asyncHandler = (handler) => (req, res, next) => {
  Promise.resolve(handler(req, res, next)).catch(next);
};

export default asyncHandler;
