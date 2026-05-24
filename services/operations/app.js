const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5056;

// Mock flight status data with intentional inconsistencies
const flightStatus = {
  'KA0924': {
    flight_num: 'KA0924', // abbreviated (vs "number" in flights service, "flightNum" in seating)
    status: 'on-time', // kebab-case (vs potential enum inconsistency across services)
    scheduled_departure: '2024-03-20T09:12:28Z', // ISO 8601 (good, but...)
    actual_departure: 1711000440000, // Unix timestamp (inconsistent with above!)
    scheduled_arrival: '2024-03-20T19:12:28Z',
    actual_arrival: null, // null when not yet departed
    gate: 'A24', // gate info not in other services
    terminal: '3',
    delay_minutes: 0,
    aircraft_registration: 'N787BA', // extra operational data
    captain: 'Captain James Smith',
    crew_size: 12
  },
  'KA0925': {
    flight_num: 'KA0925',
    status: 'DELAYED', // ALL_CAPS (inconsistent enum!)
    scheduled_departure: '2024-03-21T09:12:28Z',
    actual_departure: null,
    scheduled_arrival: '2024-03-21T19:12:28Z',
    actual_arrival: null,
    gate: null, // null for delayed flights
    terminal: null,
    delay_minutes: 45,
    aircraft_registration: 'N787BB',
    captain: 'Captain Sarah Johnson',
    crew_size: 12
  },
  'KA0926': {
    flight_num: 'KA0926',
    status: 'cancelled', // lowercase (third enum variant!)
    scheduled_departure: '2024-03-21T14:00:00Z',
    actual_departure: null,
    scheduled_arrival: '2024-03-22T00:00:00Z',
    actual_arrival: null,
    gate: null,
    terminal: null,
    delay_minutes: null, // null instead of 0 or not included
    aircraft_registration: null,
    captain: null,
    crew_size: 0,
    cancellation_reason: 'Mechanical issue'
  }
};

// Health check with non-standard response
app.get('/health', (req, res) => {
  res.json({ operational: true }); // "operational" not "status"
});

// GET flight status (different response structure)
app.get('/flights/:flightNum/status', (req, res) => {
  const { flightNum } = req.params;

  if (!flightStatus[flightNum]) {
    return res.status(404).json({
      details: {
        message: `Flight ${flightNum} not found`,
        timestamp: new Date().toISOString(),
        path: `/flights/${flightNum}/status`
      }
    });
  }

  const data = flightStatus[flightNum];
  res.json({
    flightNo: data.flight_num, // renamed again (vs flight_num above)
    operational_status: data.status, // renamed (vs "status" in data)
    departure: {
      scheduled: data.scheduled_departure,
      actual: data.actual_departure ? new Date(data.actual_departure).toISOString() : null,
      gate: data.gate,
      terminal: data.terminal
    },
    arrival: {
      scheduled: data.scheduled_arrival,
      actual: data.actual_arrival,
      gate: 'TBD'
    },
    delays: {
      minutes: data.delay_minutes,
      reason: data.status === 'cancelled' ? data.cancellation_reason : null
    },
    crew: {
      captain_name: data.captain,
      team_size: data.crew_size // "team_size" not "crew_size"
    }
  });
});

// GET crew (separate endpoint)
app.get('/flights/:flightNum/crew', (req, res) => {
  const { flightNum } = req.params;

  if (!flightStatus[flightNum]) {
    return res.status(404).json({
      error_code: 404,
      error_message: `No data for ${flightNum}` // error_message instead of message/error
    });
  }

  const data = flightStatus[flightNum];

  if (data.status === 'cancelled') {
    return res.json({
      flight: flightNum,
      crew: null,
      note: 'Flight cancelled, no crew assigned'
    });
  }

  res.json({
    flight: flightNum,
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
    ]
  });
});

// GET gate info (extra endpoint not in other services)
app.get('/flights/:flightNum/gate', (req, res) => {
  const { flightNum } = req.params;

  if (!flightStatus[flightNum]) {
    return res.status(404).json({
      statusCode: 404,
      msg: `Flight not found` // "msg" not "message" or "error"
    });
  }

  const data = flightStatus[flightNum];
  res.json({
    flight_number: flightNum, // yet another naming pattern
    departure_gate: data.gate,
    departure_terminal: data.terminal,
    baggage_claim: data.gate ? `${data.terminal}-${String.fromCharCode(65 + Math.floor(Math.random() * 3))}` : null,
    last_updated_at: Date.now(), // Unix timestamp
    next_update_in_seconds: 300
  });
});

app.listen(PORT, () => {
  console.log(`KongAir Operations Service running on port ${PORT}`);
});
