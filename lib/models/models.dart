import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String date;
  final String time;
  final int duration;
  final String patientName;
  final String patientPhone;
  final String doctorName;
  final String doctorId;
  final String status;
  final String type;
  final int tokenNumber;
  final int queuePosition;  // 0 = serving, 1+ = waiting position
  final bool isCheckedIn;   // true if patient has arrived
  
  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.duration,
    required this.patientName,
    required this.patientPhone,
    required this.doctorName,
    required this.doctorId,
    required this.status,
    required this.type,
    required this.tokenNumber,
    this.queuePosition = 0,
    this.isCheckedIn = false,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      date: json['date'] ?? '',
      time: json['time'],
      duration: json['duration'],
      patientName: json['patient_name'],
      patientPhone: json['patient_phone'] ?? '',
      doctorName: json['doctor_name'],
      doctorId: json['doctor_id'] ?? '',
      status: json['status'],
      type: json['type'],
      tokenNumber: json['token_number'] ?? 0,
      queuePosition: json['queue_position'] ?? 0,
      isCheckedIn: json['is_checked_in'] ?? false,
    );
  }
}

class StatCardData {
  final String label;
  final String value;
  final String? trend;
  final String icon;
  final String color;

  StatCardData({
    required this.label,
    required this.value,
    this.trend,
    required this.icon,
    required this.color,
  });

  factory StatCardData.fromJson(Map<String, dynamic> json) {
    return StatCardData(
      label: json['label'],
      value: json['value'],
      trend: json['trend'],
      icon: json['icon'],
      color: json['color'],
    );
  }
  
  // Helper to get IconData from string name
  IconData getIconData() {
    switch (icon) {
      case 'phone_in_talk': return Icons.phone_in_talk;
      case 'calendar_today': return Icons.calendar_today;
      case 'smart_toy': return Icons.smart_toy;
      default: return Icons.analytics;
    }
  }

  // Helper to get Color from string name
  Color getColor() {
    switch (color) {
      case 'blue': return Colors.blue;
      case 'teal': return Colors.teal;
      case 'orange': return Colors.orange;
      case 'red': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialization;

  Doctor({required this.id, required this.name, required this.specialization});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'] ?? 'General',
    );
  }

  String get avatar {
    if (name.isEmpty) return "DOC";
    var parts = name.split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  // Assign a static-like color based on ID or Name hash
  String get color {
     // Simple hash logic for demo colors
     final colors = ['0xFFE3F2FD', '0xFFE8F5E9', '0xFFFFF3E0', '0xFFF3E5F5', '0xFFE0F7FA'];
     int hash = name.codeUnits.fold(0, (a, b) => a + b);
     return colors[hash % colors.length];
  }
}

int min(int a, int b) => a < b ? a : b;

class Clinic {
  final String id;
  final String name;

  Clinic({required this.id, required this.name});

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ClinicSession {
  final String id;
  final String name;
  final String startTime;
  final String endTime;

  ClinicSession({
    required this.id, 
    required this.name, 
    required this.startTime, 
    required this.endTime
  });

  factory ClinicSession.fromJson(Map<String, dynamic> json) {
    return ClinicSession(
      id: json['id'],
      name: json['name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class CallLog {
  final String id;
  final String callerPhone;
  final String startTime;
  final int durationSeconds;
  final String classification;
  final String? transcript;
  final bool wasSuccessful;

  CallLog({
    required this.id,
    required this.callerPhone,
    required this.startTime,
    required this.durationSeconds,
    required this.classification,
    this.transcript,
    required this.wasSuccessful,
  });

  factory CallLog.fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['id'],
      callerPhone: json['caller_phone'],
      startTime: json['start_time'],
      durationSeconds: json['duration_seconds'] ?? 0,
      classification: json['classification'] ?? 'General',
      transcript: json['transcript'],
      wasSuccessful: json['was_successful'] ?? false,
    );
  }
}
