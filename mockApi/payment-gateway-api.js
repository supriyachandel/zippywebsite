const express = require('express');
const app = express();

app.use(express.json());

// Mock payment data store
const payments = new Map();
let paymentIdCounter = 1000;

// Helper to generate transaction ID
const generateTransactionId = () => `TXN-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

// Process Payment
app.post('/api/payments/process', (req, res) => {
  const { amount, cardNumber, cvv, expiryDate, customerName, orderId } = req.body;

  // Validation
  if (!amount || !cardNumber || !cvv || !expiryDate || !customerName) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields'
    });
  }

  // Mock validation rules
  if (amount <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid amount'
    });
  }

  // Simulate failed payment for test card numbers
  if (cardNumber === '4000000000000002') {
    return res.status(402).json({
      success: false,
      message: 'Insufficient funds',
      transactionId: generateTransactionId()
    });
  }

  if (cardNumber === '5555555555554444') {
    return res.status(403).json({
      success: false,
      message: 'Card declined',
      transactionId: generateTransactionId()
    });
  }

  // Successful payment
  const paymentId = `PAY-${paymentIdCounter++}`;
  const transactionId = generateTransactionId();
  
  const paymentData = {
    paymentId,
    transactionId,
    orderId: orderId || null,
    amount,
    customerName,
    status: 'completed',
    timestamp: new Date().toISOString(),
    cardLast4: cardNumber.slice(-4)
  };

  payments.set(paymentId, paymentData);

  res.status(200).json({
    success: true,
    message: 'Payment processed successfully',
    paymentId,
    transactionId,
    amount,
    status: 'completed'
  });
});

// Refund Payment
app.post('/api/payments/refund', (req, res) => {
  const { paymentId, amount } = req.body;

  if (!paymentId) {
    return res.status(400).json({
      success: false,
      message: 'Payment ID is required'
    });
  }

  const payment = payments.get(paymentId);

  if (!payment) {
    return res.status(404).json({
      success: false,
      message: 'Payment not found'
    });
  }

  if (payment.status === 'refunded') {
    return res.status(400).json({
      success: false,
      message: 'Payment already refunded'
    });
  }

  const refundAmount = amount || payment.amount;
  
  if (refundAmount > payment.amount) {
    return res.status(400).json({
      success: false,
      message: 'Refund amount cannot exceed payment amount'
    });
  }

  payment.status = 'refunded';
  payment.refundAmount = refundAmount;
  payment.refundTimestamp = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: 'Refund processed successfully',
    paymentId,
    refundAmount,
    originalAmount: payment.amount,
    status: 'refunded'
  });
});

// Get Payment Status
app.get('/api/payments/:paymentId', (req, res) => {
  const { paymentId } = req.params;

  const payment = payments.get(paymentId);

  if (!payment) {
    return res.status(404).json({
      success: false,
      message: 'Payment not found'
    });
  }

  res.status(200).json({
    success: true,
    payment: {
      paymentId: payment.paymentId,
      transactionId: payment.transactionId,
      amount: payment.amount,
      status: payment.status,
      customerName: payment.customerName,
      timestamp: payment.timestamp,
      cardLast4: payment.cardLast4
    }
  });
});

// List all payments (for testing/debugging)
app.get('/api/payments', (req, res) => {
  const paymentsList = Array.from(payments.values());

  res.status(200).json({
    success: true,
    count: paymentsList.length,
    payments: paymentsList
  });
});

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'Payment Gateway API is running',
    timestamp: new Date().toISOString()
  });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Payment Gateway API running on port ${PORT}`);
  console.log('\nTest card numbers:');
  console.log('Success: 4111111111111111');
  console.log('Insufficient funds: 4000000000000002');
  console.log('Card declined: 5555555555554444');
});
