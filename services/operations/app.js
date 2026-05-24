const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5056;

// Mock flight status data - standardized format
const flightStatus = {
  'KA0924': {
    flight_id: 'KA0924',
    flight_number: 'KA0924',
    status: 'on-time',
    scheduled_departure: '2024-03-20T09:12:28Z',
    actual_departure: '2024-03-20T09:12:28Z',
    scheduled_arrival: '2024-03-20T19:12:28Z',
    actual_arrival: null,
    gate: 'A24',
    terminal: '3',
    delayed_minutes: 0,
    aircraft_registration: 'N787BA',
    captain: 'Captain James Smith',
    crew_size: 12,
    created_at: '2024-03-20T09:00:00Z',
    updated_at: '2024-03-20T09:12:28Z'
  },
  'KA0925': {
    flight_id: 'KA0925',
    flight_number: 'KA0925',
    status: 'delayed',
    scheduled_departure: '2024-03-21T09:12:28Z',
    actual_departure: null,
    scheduled_arrival: '2024-03-21T19:12:28Z',
    actual_arrival: null,
    gate: null,
    terminal: null,
    delayed_minutes: 45,
    aircraft_registration: 'N787BB',
    captain: 'Captain Sarah Johnson',
    crew_size: 12,
    created_at: '2024-03-21T08:00:00Z',
    updated_at: '2024-03-21T09:12:28Z'
  },
  'KA0926': {
    flight_id: 'KA0926',
    flight_number: 'KA0926',
    status: 'cancelled',
    scheduled_departure: '2024-03-21T14:00:00Z',
    actual_departure: null,
    scheduled_arrival: '2024-03-22T00:00:00Z',
    actual_arrival: null,
    gate: null,
    terminal: null,
    delayed_minutes: 0,
    aircraft_registration: null,
    captain: null,
    crew_size: 0,
    cancellation_reason: 'Mechanical issue',
    created_at: '2024-03-21T08:00:00Z',
    updated_at: '2024-03-21T14:00:00Z'
  }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// GET flight status
app.get('/flights/:flightNumber/status', (req, res) => {
  const { flightNumber } = req.params;

  if (!flightStatus[flightNumber]) {
    return res.status(404).json({
      error: 'Flight not found',
      message: `Flight ${flightNumber} not found`,
      timestamp: new Date().toISOString()
    });
  }

  const data = flightStatus[flightNumber];
  res.json({
    flight_id: data.flight_id,
    flight_number: data.flight_number,
    status: data.status,
    departure: {
      scheduled: data.scheduled_departure,
      actual: data.actual_departure,
      gate: data.gate,
      terminal: data.terminal
    },
    arrival: {
      scheduled: data.scheduled_arrival,
      actual: data.actual_arrival
    },
    delayed_minutes: data.delayed_minutes,
    crew_size: data.crew_size,
    created_at: data.created_at,
    updated_at: data.updated_at
  });
});

// GET crew
app.get('/flights/:flightNumber/crew', (req, res) => {
  const { flightNumber } = req.params;

  if (!flightStatus[flightNumber]) {
    return res.status(404).json({
      error: 'Flight not found',
      message: `No data for ${flightNumber}`,
      timestamp: new Date().toISOString()
    });
  }

  const data = flightStatus[flightNumber];

  if (data.status === 'cancelled') {
    return res.json({
      flight_number: flightNumber,
      crew_members: null,
      created_at: data.created_at,
      updated_at: data.updated_at
    });
  }

  res.json({
    flight_number: flightNumber,
    crew_members: [
      {
        id: 'CREW001',
        name: data.captain,
        role: 'Captain',
        base: 'LHR',
        hours_this_month: 120
      },
      {
        id: 'CREW002',
        name: 'First Officer Michael Chen',
        role: 'First Officer',
        base: 'LHR',
        hours_this_month: 85
      },
      {
        id: 'CREW003',
        name: 'Flight Attendant Lisa Brown',
        role: 'Lead Flight Attendant',
        base: 'LHR',
        hours_this_month: 95
      }
    ],
    created_at: data.created_at,
    updated_at: data.updated_at
  });
});

// GET gate info
app.get('/flights/:flightNumber/gate', (req, res) => {
  const { flightNumber } = req.params;

  if (!flightStatus[flightNumber]) {
    return res.status(404).json({
      error: 'Flight not found',
      message: 'Flight not found',
      timestamp: new Date().toISOString()
    });
  }

  const data = flightStatus[flightNumber];
  res.json({
    flight_number: flightNumber,
    departure_gate: data.gate,
    departure_terminal: data.terminal,
    baggage_claim: data.gate ? `${data.terminal}-${String.fromCharCode(65 + Math.floor(Math.random() * 3))}` : null,
    updated_at: data.updated_at,
    created_at: data.created_at
  });
});

app.listen(PORT, () => {
  console.log(`KongAir Operations Service running on port ${PORT}`);
});
