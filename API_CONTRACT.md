# API Contract for Service Desk Frontend

> **Base URL**: `http://127.0.0.1:8000/dashboard`  
> **Content-Type**: `application/json`

---

## Authentication

### POST `/login`

Authenticate a clinic user.

**Request Body**:
```json
{
  "username": "admin",
  "password": "password123"
}
```

**Response (200)**:
```json
{
  "success": true,
  "clinic_id": "550e8400-e29b-41d4-a716-446655440000",
  "clinic_name": "Health Plus Clinic",
  "username": "admin",
  "full_name": "Admin User"
}
```

**Response (401)**: Invalid credentials

---

## Clinics

### GET `/clinics`

Fetch all clinics.

**Response (200)**:
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Health Plus Clinic"
  }
]
```

---

## Doctors

### GET `/doctors`

Fetch doctors for a clinic.

**Query Parameters**:
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `clinic_id` | string (UUID) | No | Filter by clinic |

**Response (200)**:
```json
[
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "name": "Dr. Rajesh Kumar",
    "specialization": "General Medicine"
  },
  {
    "id": "660e8400-e29b-41d4-a716-446655440002",
    "name": "Dr. Kavya Sharma",
    "specialization": "Pediatrics"
  }
]
```

---

## Sessions

### GET `/sessions`

Fetch clinic sessions (morning/evening).

**Query Parameters**:
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `clinic_id` | string (UUID) | No | Filter by clinic |

**Response (200)**:
```json
[
  {
    "id": "770e8400-e29b-41d4-a716-446655440010",
    "name": "MORNING",
    "start_time": "09:00",
    "end_time": "13:00"
  },
  {
    "id": "770e8400-e29b-41d4-a716-446655440011",
    "name": "EVENING",
    "start_time": "17:00",
    "end_time": "21:00"
  }
]
```

---

## Dashboard Stats

### GET `/stats`

Fetch dashboard statistics.

**Query Parameters**:
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `clinic_id` | string (UUID) | No | Filter by clinic |

**Response (200)**:
```json
{
  "cards": [
    {
      "label": "Incoming Calls",
      "value": "15",
      "trend": "Today",
      "icon": "phone_in_talk",
      "color": "blue"
    },
    {
      "label": "Appointments",
      "value": "32",
      "trend": "8 slots left",
      "icon": "calendar_today",
      "color": "teal"
    },
    {
      "label": "AI Success Rate",
      "value": "98%",
      "trend": "Last 24h",
      "icon": "smart_toy",
      "color": "orange"
    }
  ]
}
```

---

## Appointments

### GET `/appointments`

Fetch appointments. Supports single date or date range.

**Query Parameters**:
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `date` | string (YYYY-MM-DD) | No | Specific date |
| `start_date` | string (YYYY-MM-DD) | No | Range start |
| `end_date` | string (YYYY-MM-DD) | No | Range end |
| `clinic_id` | string (UUID) | No | Filter by clinic |

**Response (200)**:
```json
[
  {
    "id": "880e8400-e29b-41d4-a716-446655440020",
    "date": "2024-12-23",
    "time": "10:30",
    "duration": 15,
    "patient_name": "John Doe",
    "patient_phone": "+919876543210",
    "doctor_name": "Dr. Rajesh Kumar",
    "doctor_id": "660e8400-e29b-41d4-a716-446655440001",
    "status": "BOOKED",
    "type": "Consultation",
    "token_number": 5
  }
]
```

---

### POST `/appointments`

Create a new appointment.

**Request Body**:
```json
{
  "clinic_id": "550e8400-e29b-41d4-a716-446655440000",
  "doctor_id": "660e8400-e29b-41d4-a716-446655440001",
  "patient_name": "Jane Doe",
  "patient_phone": "+919876543210",
  "date": "2024-12-23",
  "time": "11:00",
  "duration": 15,
  "notes": "Follow-up visit"
}
```

**Response (200)**:
```json
{
  "success": true,
  "appointment_id": "880e8400-e29b-41d4-a716-446655440021"
}
```

**Response (400)**:
```json
{
  "detail": "Slot not available"
}
```

---

## Call Logs

### GET `/calls`

Fetch call logs.

**Query Parameters**:
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `clinic_id` | string (UUID) | No | Filter by clinic |
| `limit` | int | No | Max results (default 50) |

**Response (200)**:
```json
[
  {
    "id": "990e8400-e29b-41d4-a716-446655440030",
    "caller_phone": "+919876543210",
    "start_time": "2024-12-23 10:15:30",
    "duration_seconds": 120,
    "classification": "Appointment Booking",
    "transcript": "Patient called to book appointment...",
    "was_successful": true,
    "sentiment": "Neutral"
  }
]
```

---

## Queue Management

### GET `/queue`

Get current queue status.

**Query Parameters**:
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `clinic_id` | string (UUID) | **Yes** | Clinic ID |
| `date_str` | string (YYYY-MM-DD) | No | Date (defaults to today) |

**Response (200)**:
```json
{
  "current_token": 3,
  "total_tokens": 15,
  "serving": {
    "id": "880e8400-e29b-41d4-a716-446655440020",
    "token_number": 3,
    "patient_name": "John Doe",
    "status": "SERVING"
  },
  "waiting": [
    {
      "id": "880e8400-e29b-41d4-a716-446655440021",
      "token_number": 4,
      "patient_name": "Jane Doe",
      "status": "BOOKED"
    }
  ],
  "completed": 2
}
```

---

### POST `/queue/status`

Update a token's status.

**Request Body**:
```json
{
  "appointment_id": "880e8400-e29b-41d4-a716-446655440020",
  "status": "VISITED"
}
```

**Status Values**: `BOOKED`, `SERVING`, `VISITED`, `SKIPPED`, `NO_SHOW`

**Response (200)**:
```json
{
  "success": true
}
```

---

### POST `/queue/next`

Call the next patient in queue.

**Query Parameters**:
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `clinic_id` | string (UUID) | **Yes** | Clinic ID |

**Response (200)**:
```json
{
  "success": true,
  "message": "Now serving Token 4",
  "token": 4,
  "patient": "Jane Doe"
}
```

---

## Data Models (Flutter)

These models should match the API responses:

### Appointment
```dart
class Appointment {
  final String id;
  final String date;
  final String time;
  final int duration;
  final String patientName;
  final String patientPhone;
  final String doctorName;
  final String? doctorId;
  final String status;
  final String type;
  final int? tokenNumber;
}
```

### Doctor
```dart
class Doctor {
  final String id;
  final String name;
  final String? specialization;
}
```

### Clinic
```dart
class Clinic {
  final String id;
  final String name;
}
```

### StatCardData
```dart
class StatCardData {
  final String label;
  final String value;
  final String? trend;
  final String icon;
  final String color;
}
```

### CallLog
```dart
class CallLog {
  final String id;
  final String callerPhone;
  final String startTime;
  final int durationSeconds;
  final String classification;
  final String? transcript;
  final bool wasSuccessful;
  final String sentiment;
}
```

---

## Error Handling

All error responses follow this format:

```json
{
  "detail": "Error message here"
}
```

| Status Code | Meaning |
|-------------|---------|
| 200 | Success |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (invalid credentials) |
| 404 | Not Found |
| 500 | Server Error |

---

## Environment Configuration

Update `baseUrl` in `lib/services/api_service.dart`:

```dart
// For local development (Windows/Web)
static const String baseUrl = 'http://127.0.0.1:8000/dashboard';

// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/dashboard';

// For production (replace with actual URL)
static const String baseUrl = 'https://your-api.com/dashboard';
```

---

## Quick Reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/login` | POST | Authenticate user |
| `/clinics` | GET | List clinics |
| `/doctors` | GET | List doctors |
| `/sessions` | GET | List sessions |
| `/stats` | GET | Dashboard statistics |
| `/appointments` | GET | List appointments |
| `/appointments` | POST | Create appointment |
| `/calls` | GET | Call logs |
| `/queue` | GET | Queue status |
| `/queue/status` | POST | Update token status |
| `/queue/next` | POST | Call next patient |
