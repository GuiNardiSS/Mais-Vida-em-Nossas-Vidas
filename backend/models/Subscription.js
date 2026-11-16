import mongoose from 'mongoose';

export const SUBSCRIPTION_STATUSES = ['pending', 'active', 'expired', 'cancelled'];

const deviceInfoSchema = new mongoose.Schema(
  {
    platform: { type: String, trim: true, maxlength: 64 },
    model: { type: String, trim: true, maxlength: 128 },
    version: { type: String, trim: true, maxlength: 64 },
  },
  { _id: false }
);

const subscriptionSchema = new mongoose.Schema(
  {
    deviceId: {
      type: String,
      required: true,
      unique: true,
      index: true,
      trim: true,
      maxlength: 128,
    },
    status: {
      type: String,
      enum: SUBSCRIPTION_STATUSES,
      default: 'pending',
      index: true,
    },
    paymentMethod: {
      type: String,
      enum: ['pix', 'card', 'demo', 'none'],
      default: 'none',
    },
    amount: {
      type: Number,
      default: 0,
      min: 0,
    },
    transactionId: {
      type: String,
      trim: true,
      maxlength: 128,
    },
    lastPaymentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Payment',
      index: true,
    },
    paymentIds: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Payment',
      },
    ],
    startDate: { type: Date },
    expiryDate: {
      type: Date,
      required: true,
      index: true,
    },
    deviceInfo: deviceInfoSchema,
    cancelledAt: { type: Date },
    revokedAt: { type: Date },
    revocationReason: { type: String, trim: true, maxlength: 200 },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform: (_doc, ret) => {
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Consultas de expiração em lote (ex.: job de manutenção).
subscriptionSchema.index({ status: 1, expiryDate: 1 });

/** Assinatura válida = status ativo e expiração no futuro. */
subscriptionSchema.methods.isActive = function isActive() {
  return (
    this.status === 'active' &&
    this.expiryDate instanceof Date &&
    this.expiryDate.getTime() > Date.now()
  );
};

subscriptionSchema.methods.daysRemaining = function daysRemaining() {
  if (!this.isActive()) return 0;
  return Math.ceil((this.expiryDate.getTime() - Date.now()) / 86_400_000);
};

/**
 * Renova a partir da data de expiração atual (ou de hoje, se já expirou),
 * sem encurtar assinaturas ainda válidas.
 */
subscriptionSchema.methods.renew = function renew(months = 1) {
  const base =
    this.expiryDate instanceof Date && this.expiryDate.getTime() > Date.now()
      ? new Date(this.expiryDate)
      : new Date();

  base.setMonth(base.getMonth() + months);
  this.expiryDate = base;
  this.status = 'active';
  this.startDate = this.startDate || new Date();
  this.cancelledAt = undefined;
  this.revokedAt = undefined;
  this.revocationReason = undefined;
  return this.save();
};

/** Cancela a assinatura (ação do usuário). */
subscriptionSchema.methods.cancel = function cancel(reason) {
  this.status = 'cancelled';
  this.cancelledAt = new Date();
  this.revocationReason = reason;
  return this.save();
};

/** Revoga a assinatura (estorno, fraude, cancelamento no provedor). */
subscriptionSchema.methods.revoke = function revoke(reason) {
  this.status = 'cancelled';
  this.revokedAt = new Date();
  this.revocationReason = reason;
  return this.save();
};

const Subscription = mongoose.model('Subscription', subscriptionSchema);

export default Subscription;
