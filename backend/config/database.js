import mongoose from 'mongoose';

/**
 * Conecta ao MongoDB. Retorna a conexão ativa.
 * Não engole erros: quem chama decide se a API pode subir sem banco.
 */
export async function connectDB(uri = process.env.MONGODB_URI, { logger } = {}) {
  if (mongoose.connection.readyState === 1) {
    return mongoose.connection;
  }

  if (!uri) {
    throw new Error('MONGODB_URI não configurada.');
  }

  await mongoose.connect(uri, {
    serverSelectionTimeoutMS: 10_000,
  });

  logger?.info?.('mongodb conectado', { database: mongoose.connection.name });
  return mongoose.connection;
}

export async function disconnectDB({ logger } = {}) {
  if (mongoose.connection.readyState === 0) return;

  await mongoose.disconnect();
  logger?.info?.('mongodb desconectado');
}

/** true somente quando a conexão está realmente pronta para operar. */
export const isDBConnected = () => mongoose.connection.readyState === 1;

export default { connectDB, disconnectDB, isDBConnected };
