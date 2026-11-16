import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import { createApp } from '../../app.js';
import { loadEnv } from '../../config/env.js';
import Payment from '../../models/Payment.js';
import Subscription from '../../models/Subscription.js';

export const DEVICE_A = 'device-test-aaaa';
export const DEVICE_B = 'device-test-bbbb';

/** Cria um env válido com NODE_ENV=test e overrides. */
export function buildEnv(overrides = {}) {
  return loadEnv({ ...process.env, NODE_ENV: 'test', ...overrides });
}

/**
 * Sobe um MongoMemoryServer + conexão Mongoose isolada e um app Express.
 * Cada suíte usa seu próprio banco em memória.
 */
export async function startTestContext(envOverrides = {}) {
  const mongo = await MongoMemoryServer.create();
  const uri = mongo.getUri();
  const env = buildEnv({ MONGODB_URI: uri, ...envOverrides });

  await mongoose.connect(uri);

  const app = createApp({ env });
  let closed = false;

  return {
    app,
    env,
    mongo,
    uri,
    /** Cria outro app (mesmo banco, mesma conexão) com overrides de env. */
    buildApp: (overrides = {}) => createApp({ env: buildEnv({ MONGODB_URI: uri, ...overrides }) }),
    async close() {
      if (closed) return;
      closed = true;
      await mongoose.disconnect();
      await mongo.stop();
    },
  };
}

let counter = 0;
export const uniqueExternalId = (prefix = 'ext') => {
  counter += 1;
  return `${prefix}_${Date.now()}_${counter}`;
};

export const seedPayment = (overrides = {}) =>
  Payment.create({
    provider: 'mock',
    method: 'pix',
    deviceId: DEVICE_A,
    amount: 499,
    currency: 'BRL',
    status: 'pending',
    txid: `txid${Date.now()}${counter}`,
    externalId: uniqueExternalId('mock'),
    expiresAt: new Date(Date.now() + 3_600_000),
    ...overrides,
  });

export const seedSubscription = (overrides = {}) =>
  Subscription.create({
    deviceId: DEVICE_A,
    status: 'active',
    paymentMethod: 'pix',
    amount: 499,
    expiryDate: new Date(Date.now() + 30 * 86_400_000),
    startDate: new Date(),
    ...overrides,
  });
