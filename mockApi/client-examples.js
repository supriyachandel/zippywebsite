// ============================================
// CLIENT INTEGRATION EXAMPLES
// ============================================

// Base URLs
const PAYMENT_API = 'http://localhost:3001';
const DELIVERY_API = 'http://localhost:3002';

// ============================================
// PAYMENT GATEWAY CLIENT
// ============================================

class PaymentGatewayClient {
  constructor(baseUrl = PAYMENT_API) {
    this.baseUrl = baseUrl;
  }

  async processPayment(paymentData) {
    try {
      const response = await fetch(`${this.baseUrl}/api/payments/process`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(paymentData)
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Payment failed');
      }

      return data;
    } catch (error) {
      console.error('Payment processing error:', error);
      throw error;
    }
  }

  async refundPayment(paymentId, amount = null) {
    try {
      const response = await fetch(`${this.baseUrl}/api/payments/refund`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ paymentId, amount })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Refund failed');
      }

      return data;
    } catch (error) {
      console.error('Refund error:', error);
      throw error;
    }
  }

  async getPaymentStatus(paymentId) {
    try {
      const response = await fetch(`${this.baseUrl}/api/payments/${paymentId}`);
      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Failed to fetch payment status');
      }

      return data.payment;
    } catch (error) {
      console.error('Error fetching payment status:', error);
      throw error;
    }
  }

  async getAllPayments() {
    try {
      const response = await fetch(`${this.baseUrl}/api/payments`);
      const data = await response.json();
      return data.payments;
    } catch (error) {
      console.error('Error fetching payments:', error);
      throw error;
    }
  }

  async checkHealth() {
    try {
      const response = await fetch(`${this.baseUrl}/health`);
      return await response.json();
    } catch (error) {
      console.error('Health check failed:', error);
      return { status: 'unreachable' };
    }
  }
}

// ============================================
// DELIVERY AGENTS CLIENT
// ============================================

class DeliveryAgentsClient {
  constructor(baseUrl = DELIVERY_API) {
    this.baseUrl = baseUrl;
  }

  async createDelivery(deliveryData) {
    try {
      const response = await fetch(`${this.baseUrl}/api/deliveries/create`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(deliveryData)
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Failed to create delivery');
      }

      return data;
    } catch (error) {
      console.error('Error creating delivery:', error);
      throw error;
    }
  }

  async assignAgent(deliveryId, agentId) {
    try {
      const response = await fetch(
        `${this.baseUrl}/api/deliveries/${deliveryId}/assign`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ agentId })
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Failed to assign agent');
      }

      return data;
    } catch (error) {
      console.error('Error assigning agent:', error);
      throw error;
    }
  }

  async updateDeliveryStatus(deliveryId, statusData) {
    try {
      const response = await fetch(
        `${this.baseUrl}/api/deliveries/${deliveryId}/status`,
        {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(statusData)
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Failed to update status');
      }

      return data;
    } catch (error) {
      console.error('Error updating delivery status:', error);
      throw error;
    }
  }

  async getDeliveryStatus(deliveryId) {
    try {
      const response = await fetch(
        `${this.baseUrl}/api/deliveries/${deliveryId}`
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Failed to fetch delivery status');
      }

      return data.delivery;
    } catch (error) {
      console.error('Error fetching delivery status:', error);
      throw error;
    }
  }

  async getAllDeliveries(filters = {}) {
    try {
      const params = new URLSearchParams(filters);
      const response = await fetch(
        `${this.baseUrl}/api/deliveries?${params.toString()}`
      );

      const data = await response.json();
      return data.deliveries;
    } catch (error) {
      console.error('Error fetching deliveries:', error);
      throw error;
    }
  }

  async getAllAgents(filters = {}) {
    try {
      const params = new URLSearchParams(filters);
      const response = await fetch(
        `${this.baseUrl}/api/agents?${params.toString()}`
      );

      const data = await response.json();
      return data.agents;
    } catch (error) {
      console.error('Error fetching agents:', error);
      throw error;
    }
  }

  async getAgentDetails(agentId) {
    try {
      const response = await fetch(`${this.baseUrl}/api/agents/${agentId}`);

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Failed to fetch agent details');
      }

      return data.agent;
    } catch (error) {
      console.error('Error fetching agent details:', error);
      throw error;
    }
  }

  async trackDelivery(deliveryId) {
    try {
      const response = await fetch(`${this.baseUrl}/api/track/${deliveryId}`);

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Failed to track delivery');
      }

      return data.tracking;
    } catch (error) {
      console.error('Error tracking delivery:', error);
      throw error;
    }
  }

  async checkHealth() {
    try {
      const response = await fetch(`${this.baseUrl}/health`);
      return await response.json();
    } catch (error) {
      console.error('Health check failed:', error);
      return { status: 'unreachable' };
    }
  }
}

// ============================================
// USAGE EXAMPLES
// ============================================

// Initialize clients
const paymentClient = new PaymentGatewayClient();
const deliveryClient = new DeliveryAgentsClient();

// -------- PAYMENT EXAMPLES --------

async function exampleCheckout(orderData) {
  try {
    console.log('Processing payment...');

    // Process payment
    const paymentResult = await paymentClient.processPayment({
      amount: orderData.totalAmount,
      cardNumber: '4111111111111111', // Test success card
      cvv: '123',
      expiryDate: '12/25',
      customerName: orderData.customerName,
      orderId: orderData.orderId
    });

    if (paymentResult.success) {
      console.log('✅ Payment successful:', paymentResult.paymentId);

      // Now create delivery
      return await createDeliveryForOrder(orderData, paymentResult);
    } else {
      console.log('❌ Payment failed:', paymentResult.message);
      throw new Error(paymentResult.message);
    }
  } catch (error) {
    console.error('Checkout failed:', error.message);
    throw error;
  }
}

async function createDeliveryForOrder(orderData, paymentResult) {
  try {
    console.log('Creating delivery order...');

    const deliveryResult = await deliveryClient.createDelivery({
      orderId: orderData.orderId,
      customerName: orderData.customerName,
      address: orderData.address,
      city: orderData.city,
      phone: orderData.phone,
      weight: orderData.weight || '1kg'
    });

    console.log('✅ Delivery created:', deliveryResult.deliveryId);

    return {
      order: orderData.orderId,
      payment: paymentResult.paymentId,
      delivery: deliveryResult.deliveryId,
      estimatedDelivery: deliveryResult.estimatedDelivery,
      agent: deliveryResult.assignedAgent
    };
  } catch (error) {
    console.error('Failed to create delivery:', error.message);
    throw error;
  }
}

async function exampleTrackOrder(deliveryId) {
  try {
    const tracking = await deliveryClient.trackDelivery(deliveryId);

    console.log('Tracking Information:');
    console.log('Status:', tracking.status);
    console.log('Location:', tracking.currentLocation);
    console.log('ETA:', tracking.estimatedDelivery);
    console.log('Agent Phone:', tracking.agentPhone);

    return tracking;
  } catch (error) {
    console.error('Failed to track delivery:', error.message);
    throw error;
  }
}

async function exampleReturnProcess(paymentId, deliveryId) {
  try {
    console.log('Processing return...');

    // Update delivery status to return
    await deliveryClient.updateDeliveryStatus(deliveryId, {
      status: 'pending', // Mark as return pending
      notes: 'Customer initiated return'
    });

    // Refund the payment
    const refundResult = await paymentClient.refundPayment(paymentId);

    console.log('✅ Return processed successfully');
    console.log('Refund Amount:', refundResult.refundAmount);

    return refundResult;
  } catch (error) {
    console.error('Return process failed:', error.message);
    throw error;
  }
}

async function exampleGetAvailableAgents(city) {
  try {
    const agents = await deliveryClient.getAllAgents({ city, status: 'available' });

    console.log(`Available agents in ${city}:`);
    agents.forEach(agent => {
      console.log(`- ${agent.name} (${agent.id}): ${agent.phone}`);
    });

    return agents;
  } catch (error) {
    console.error('Failed to fetch agents:', error.message);
    throw error;
  }
}

// ============================================
// REACT COMPONENT EXAMPLE
// ============================================

const ReactCheckoutExample = () => {
  const [loading, setLoading] = React.useState(false);
  const [orderStatus, setOrderStatus] = React.useState(null);
  const [error, setError] = React.useState(null);

  const handleCheckout = async (formData) => {
    setLoading(true);
    setError(null);

    try {
      const result = await exampleCheckout({
        orderId: `ORD-${Date.now()}`,
        customerName: formData.customerName,
        totalAmount: formData.totalAmount,
        address: formData.address,
        city: formData.city,
        phone: formData.phone,
        weight: formData.weight
      });

      setOrderStatus(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleTrack = async (deliveryId) => {
    try {
      const tracking = await exampleTrackOrder(deliveryId);
      setOrderStatus(prev => ({
        ...prev,
        tracking: tracking
      }));
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div>
      {loading && <p>Processing...</p>}
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}
      {orderStatus && (
        <div>
          <h3>Order Confirmed!</h3>
          <p>Order ID: {orderStatus.order}</p>
          <p>Delivery ID: {orderStatus.delivery}</p>
          <p>Estimated Delivery: {orderStatus.estimatedDelivery}</p>
          <p>Agent: {orderStatus.agent?.name}</p>
          <button onClick={() => handleTrack(orderStatus.delivery)}>
            Track Order
          </button>
        </div>
      )}
    </div>
  );
};

// ============================================
// NODEJS/EXPRESS MIDDLEWARE EXAMPLE
// ============================================

const paymentMiddleware = async (req, res, next) => {
  try {
    const paymentResult = await paymentClient.processPayment(req.body.payment);
    req.paymentResult = paymentResult;
    next();
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const createOrderWithDelivery = async (req, res) => {
  try {
    const paymentResult = req.paymentResult;

    const deliveryResult = await deliveryClient.createDelivery({
      orderId: req.body.orderId,
      customerName: req.body.customerName,
      address: req.body.address,
      city: req.body.city,
      phone: req.body.phone
    });

    res.status(200).json({
      success: true,
      order: {
        id: req.body.orderId,
        paymentId: paymentResult.paymentId,
        deliveryId: deliveryResult.deliveryId,
        estimatedDelivery: deliveryResult.estimatedDelivery
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    PaymentGatewayClient,
    DeliveryAgentsClient,
    paymentClient,
    deliveryClient,
    exampleCheckout,
    exampleTrackOrder,
    exampleReturnProcess,
    exampleGetAvailableAgents
  };
}
