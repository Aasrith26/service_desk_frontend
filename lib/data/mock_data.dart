import 'dart:math';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String avatar;
  final String color; // Hex color for calendar

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatar,
    required this.color,
  });
}

class Patient {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String history;

  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.history,
  });
}

class Appointment {
  final String id;
  final String patientId; // Linked to Patient
  final DateTime date; // New date field
  final String time;
  final int duration;
  final String type;
  final String doctorId;
  final String status;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.date,
    required this.time,
    required this.duration,
    required this.type,
    required this.doctorId,
    required this.status,
  });
}

class Call {
  final String id;
  final String callerName;
  final String time;
  final DateTime date;
  final String status; // 'missed', 'completed', 'voicemail'

  const Call({required this.id, required this.callerName, required this.time, required this.date, required this.status});
}

const List<Doctor> doctors = [
  Doctor(id: 'dr-1', name: 'Dr. Sarah Smith', specialty: 'Cardiology', avatar: 'SS', color: '0xFFE3F2FD'),
  Doctor(id: 'dr-2', name: 'Dr. James Chen', specialty: 'Pediatrics', avatar: 'JC', color: '0xFFE8F5E9'),
  Doctor(id: 'dr-3', name: 'Dr. Emily White', specialty: 'General', avatar: 'EW', color: '0xFFFFF3E0'),
];

const List<Patient> patients = [
  Patient(id: 'p-1', name: 'Alice Johnson', phone: '+1 (555) 012-3456', email: 'alice.j@example.com', history: 'Hypertension, Allergies (Penicillin)'),
  Patient(id: 'p-2', name: 'Bob Brown', phone: '+1 (555) 012-7890', email: 'bob.b@example.com', history: 'Asthma, clear chest x-ray 2023'),
  Patient(id: 'p-3', name: 'Charlie Davis', phone: '+1 (555) 012-1122', email: 'charlie.d@example.com', history: 'Post-surgery recovery (ACL)'),
  Patient(id: 'p-4', name: 'Diana Prince', phone: '+1 (555) 012-3344', email: 'diana.p@example.com', history: 'Regular check-ups, no major issues'),
  Patient(id: 'p-5', name: 'Evan Wright', phone: '+1 (555) 012-5566', email: 'evan.w@example.com', history: 'Diabetes Type 2, managed'),
];

// Helper to get patient by ID
Patient getPatient(String id) => patients.firstWhere((p) => p.id == id, orElse: () => patients[0]);

// Helper to get doctor by ID
Doctor getDoctor(String id) => doctors.firstWhere((d) => d.id == id, orElse: () => doctors[0]);

final DateTime now = DateTime.now();
final DateTime today = DateTime(now.year, now.month, now.day);

final List<Appointment> initialAppointments = [
  Appointment(id: '1', patientId: 'p-1', date: today, time: '09:00', duration: 45, type: 'Consultation', doctorId: 'dr-1', status: 'in-progress'),
  Appointment(id: '2', patientId: 'p-2', date: today, time: '10:00', duration: 30, type: 'Walk-in', doctorId: 'dr-3', status: 'waiting'),
  Appointment(id: '3', patientId: 'p-3', date: today, time: '11:00', duration: 60, type: 'Surgery', doctorId: 'dr-1', status: 'scheduled'),
  Appointment(id: '4', patientId: 'p-4', date: today.add(const Duration(days: 1)), time: '09:30', duration: 30, type: 'Follow-up', doctorId: 'dr-2', status: 'scheduled'), // Tomorrow
  Appointment(id: '5', patientId: 'p-5', date: today, time: '14:00', duration: 45, type: 'Consultation', doctorId: 'dr-3', status: 'scheduled'),
];

final List<Call> mockCalls = [
  Call(id: 'c-1', callerName: 'Unknown', time: '08:30', date: today, status: 'missed'),
  Call(id: 'c-2', callerName: 'Alice Johnson', time: '08:45', date: today, status: 'completed'),
  Call(id: 'c-3', callerName: 'Bob Brown', time: '09:15', date: today, status: 'completed'),
  Call(id: 'c-4', callerName: 'Pharmacy', time: '09:20', date: today, status: 'voicemail'),
  Call(id: 'c-5', callerName: 'Insurance Co', time: '14:00', date: today.subtract(const Duration(days: 1)), status: 'completed'), // Yesterday
];
