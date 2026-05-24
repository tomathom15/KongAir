const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = process.env.PORT || 5057;

// Mock ancillary data - standardized format
const bookingAddOns = {
  'BK001': {
    booking_id: 'BK001',
    flight_id: 'KA0924',
    passenger_name: 'John Doe',
    add_ons: [
      {
        id: 'ADDON001',
        type: 'seat_upgrade',
        from_seat: '32B',
        to_seat: '12A',
        price: 149.99,
        status: 'confirmed',
        created_at: '2024-03-20T09:00:00Z',
        updated_at: '2024-03-20T09:12:28Z'
      },
      {
        id: 'ADDON002',
        type: 'baggage',
        quantity: 1,
        weight: 23,
        price: 50.00,
        status: 'confirmed',
        created_at: '2024-03-20T09:05:00Z',
        updated_at: '2024-03-20T09:12:28Z'
      }
    ],
    created_at: '2024-03-20T09:00:00Z',
    updated_at: '2024-03-20T09:12:28Z'
  }
};

const baggagePolicies = {
  'LHR-SFO': {
    route_id: 'LHR-SFO',
    origin: 'LHR',
    destination: 'SFO',
    free_baggage_allowance: 1,
    max_weight_per_bag: 23,
    carry_on_allowed: {
      count: 1,
      dimensions: '22x14x9'
    },
    excess_baggage_fee: 50.00,
    created_at: '2024-03-20T08:00:00Z',
    updated_at: '2024-03-20T08:00:00Z'
  }
};

const mealOptions = {
  'KA0924': {
    flight_id: 'KA0924',
    meals: [
      {
        meal_type: 'breakfast',
        dietary_options: ['vegan', 'gluten-free', 'halal'],
        price: 12.00,
        available_count: 45
      },
      {
        meal_type: 'lunch',
        dietary_options: ['vegan', 'vegetarian', 'standard'],
        price: 18.00,
        available_count: 120
      }
    ],
    created_at: '2024-03-20T08:00:00Z',
    updated_at: '2024-03-20T08:00:00Z'
  }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// GET add-ons for a booking
app.get('/bookings/:bookingId/add-ons', (req, res) => {
  const { bookingId } = req.params;

  if (!bookingAddOns[bookingId]) {
    return res.status(404).json({
      error: 'Booking not found',
      message: `Booking ${bookingId} not found`,
      timestamp: new Date().toISOString()
    });
  }

  const data = bookingAddOns[bookingId];
  res.json({
    booking_id: data.booking_id,
    add_ons: data.add_ons,
    total_price: data.add_ons.reduce((sum, a) => sum + (a.price || 0), 0),
    created_at: data.created_at,
    updated_at: data.updated_at
  });
});

// POST new add-on
app.post('/bookings/:bookingId/add-ons', (req, res) => {
  const { bookingId } = req.params;
  const { type, details } = req.body;

  if (!bookingId || !type) {
    return res.status(400).json({
      error: 'Bad request',
      message: 'Missing required fields',
      timestamp: new Date().toISOString()
    });
  }

  const now = new Date().toISOString();
  const addon = {
    id: `ADDON${Date.now()}`,
    type: type,
    ...details,
    created_at: now,
    updated_at: now
  };

  if (!bookingAddOns[bookingId]) {
    bookingAddOns[bookingId] = {
      booking_id: bookingId,
      add_ons: [],
      created_at: now,
      updated_at: now
    };
  }

  bookingAddOns[bookingId].add_ons.push(addon);
  bookingAddOns[bookingId].updated_at = now;

  res.status(201).json({
    id: addon.id,
    booking_id: bookingId,
    created_at: now,
    updated_at: now
  });
});

// GET baggage policy
app.get('/routes/:routeId/baggage-policy', (req, res) => {
  const { routeId } = req.params;

  if (!baggagePolicies[routeId]) {
    return res.status(404).json({
      error: 'Route not found',
      message: `Policy for route ${routeId} not found`,
      timestamp: new Date().toISOString()
    });
  }

  const policy = baggagePolicies[routeId];
  res.json({
    route_id: policy.route_id,
    origin: policy.origin,
    destination: policy.destination,
    free_baggage_allowance: policy.free_baggage_allowance,
    max_weight_per_bag: policy.max_weight_per_bag,
    carry_on_allowed: policy.carry_on_allowed,
    excess_baggage_fee: policy.excess_baggage_fee,
    created_at: policy.created_at,
    updated_at: policy.updated_at
  });
});

// GET meal options
app.get('/flights/:flightId/meals', (req, res) => {
  const { flightId } = req.params;

  if (!mealOptions[flightId]) {
    return res.status(404).json({
      error: 'Flight not found',
      message: `No meals available for flight ${flightId}`,
      timestamp: new Date().toISOString()
    });
  }

  const options = mealOptions[flightId];
  res.json({
    flight_id: options.flight_id,
    meals: options.meals.map(meal => ({
      meal_type: meal.meal_type,
      dietary_options: meal.dietary_options,
      price: meal.price,
      available_count: meal.available_count
    })),
    created_at: options.created_at,
    updated_at: options.updated_at
  });
});

// GET meal preferences
app.get('/customer/:customerId/meal-preferences', (req, res) => {
  const { customerId } = req.params;

  res.json({
    customer_id: customerId,
    dietary_options: ['vegetarian', 'nut-allergy'],
    cuisine_preference: 'Asian',
    special_requests: 'Aisle seat preferred',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`KongAir Ancillary Services running on port ${PORT}`);
});
