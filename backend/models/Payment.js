import mongoose from 'mongoose';

export const PAYMENT_STATUSES = [
  'pending',
  'paid',
  'expired',
  'cancelled',
  'refunded',
  'failed',
];

const paymentEventSchema = new mongoose.Schema(
  {
    type: { type: String, required: true },
    source: { type: String, required: true },
    at: { type: Date, default: Date.now },
  },
  { _id: false }
);

const paymentSchema = new mongoose.Schema(
  {
    provider: {
      type: String,
      enum: ['mock', 'mercadopago', 'asaas', 'efi', 'stripe'],
      required: true,
      index: true,
    },
    method: {
      type: String,
      enum: ['pix', 'card'],
      required: true,
      index: true,
    },
    deviceId: {
      type: String,
      required: true,
      trim: true,
      maxlength: 128,
      index: true,
    },
    amount: {
      type: Number,
      required: true,
      min: 1,
    },
    currency: { type: String, default: 'BRL', uppercase: true },
    status: {
      type: String,
      enum: PAYMENT_STATUSES,
      default: 'pending',
      index: true,
    },
    externalId: { type: String, trim: true },
    txid: { type: String, trim: true },
    brCode: { type: String },
    qrCodeImage: { type: String },
    expiresAt: { type: Date, index: true },
    paidAt: { type: Date },
    failedAt: { type: Date },
    refundedAt: { type: Date },
    revokedAt: { type: Date },
    entitlementApplied: { type: Boolean, default: false, index: true },
    entitlementAppliedAt: { type: Date },
    metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
    events: { type: [paymentEventSchema], default: [] },
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

paymentSchema.index({ deviceId: 1, createdAt: -1 });
paymentSchema.index({ status: 1, expiresAt: 1 });
paymentSchema.index(
  { provider: 1, externalId: 1 },
  {
    unique: true,
    partialFilterExpression: { externalId: { $type: 'string' } },
  }
);

paymentSchema.methods.isPaid = function isPaid() {
  return this.status === 'paid';
};

paymentSchema.methods.isExpired = function isExpired() {
  return (
    this.status === 'pending' &&
    this.expiresAt instanceof Date &&
    this.expiresAt.getTime() <= Date.now()
  );
};

const Payment = mongoose.model('Payment', paymentSchema);

export default Payment;
