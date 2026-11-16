process.env.NODE_ENV = 'test';
process.env.LOG_LEVEL = 'silent';

process.env.JWT_SECRET = 'test-jwt-secret-with-at-least-16-chars';
process.env.DEMO_MODE = 'true';
process.env.DEMO_ACTIVATION_TOKEN = 'demo-token-test';
process.env.PIX_PROVIDER = 'mock';
process.env.PIX_KEY = 'demo@maisvida.app';
process.env.PIX_RECEIVER_NAME = 'MAIS VIDA';
process.env.PIX_RECEIVER_CITY = 'SAO PAULO';
process.env.CORS_ORIGIN = 'http://allowed.example,http://localhost:3000';
process.env.STRIPE_WEBHOOK_SECRET = 'whsec_test_secret';

// Limites altos para não interferir nos testes funcionais; o teste específico
// de rate limit cria um app com valores baixos via buildEnv().
process.env.RATE_LIMIT_GENERAL_MAX = '100000';
process.env.RATE_LIMIT_PAYMENT_MAX = '1000';
process.env.RATE_LIMIT_VALIDATION_MAX = '1000';
