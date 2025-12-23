import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Use 127.0.0.1 for Windows/Web. Use 10.0.2.2 for Android Emulator.
  static const String baseUrl = 'http://127.0.0.1:8000/dashboard';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return null; // Invalid creds
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  Future<List<Appointment>> fetchAppointments({String? date}) async {
    String query = "";
    if (date != null) query = "?date=$date";
    final uri = Uri.parse('$baseUrl/appointments$query');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Appointment.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
       print("API Error: $e");
       rethrow;
    }
  }

  Future<List<Appointment>> fetchAppointmentsRange({required String startDate, required String endDate, String? clinicId}) async {
    String query = "?start_date=$startDate&end_date=$endDate";
    if (clinicId != null) query += "&clinic_id=$clinicId";
    final uri = Uri.parse('$baseUrl/appointments$query');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Appointment.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load appointments range: ${response.statusCode}');
      }
    } catch (e) {
       print("API Error: $e");
       rethrow;
    }
  }

  Future<List<StatCardData>> fetchStats({String? clinicId}) async {
    String query = "";
    if (clinicId != null) query = "?clinic_id=$clinicId";
    final uri = Uri.parse('$baseUrl/stats$query');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> cards = data['cards'];
        return cards.map((item) => StatCardData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }

  Future<List<Doctor>> fetchDoctors({String? clinicId}) async {
    String query = "";
    if (clinicId != null) query = "?clinic_id=$clinicId";
    final uri = Uri.parse('$baseUrl/doctors$query');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Doctor.fromJson(item)).toList();
      } else {
         throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (e) {
       print("API Error: $e");
       return [];
    }
  }

  Future<List<ClinicSession>> fetchSessions({String? clinicId}) async {
    String query = "";
    if (clinicId != null) query = "?clinic_id=$clinicId";
    final uri = Uri.parse('$baseUrl/sessions$query');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => ClinicSession.fromJson(item)).toList();
      } else {
         // Fallback or empty if not found
         return [];
      }
    } catch (e) {
       print("API Error Sessions: $e");
       return [];
    }
  }

  Future<List<Clinic>> fetchClinics() async {
    final uri = Uri.parse('$baseUrl/clinics');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Clinic.fromJson(item)).toList();
      } else {
         throw Exception('Failed to load clinics: ${response.statusCode}');
      }
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }

  Future<String?> createAppointment({
    required String clinicId,
    required String doctorId,
    required String patientName,
    required String patientPhone,
    required String date,
    required String time,
  }) async {
    final uri = Uri.parse('$baseUrl/appointments');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clinic_id': clinicId,
          'doctor_id': doctorId,
          'patient_name': patientName,
          'patient_phone': patientPhone,
          'date': date,
          'time': time,
          'duration': 15 // Fixed for now
        }),
      );
      
      if (response.statusCode == 200) {
          return null; // Success
      } else {
          // Try to decode error message
          try {
              final body = jsonDecode(response.body);
              if (body['detail'] != null) return body['detail'];
          } catch (_) {}
          return "Failed to schedule: ${response.statusCode}";
      }
    } catch (e) {
      print("API Error: $e");
      return "Network Error: $e";
    }
  }

  Future<List<CallLog>> fetchCallLogs({String? clinicId}) async {
    String query = "";
    if (clinicId != null) query = "?clinic_id=$clinicId";
    final uri = Uri.parse('$baseUrl/calls$query');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => CallLog.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load call logs: ${response.statusCode}');
      }
    } catch (e) {
       print("API Error: $e");
       return [];
    }
  }
  Future<Map<String, dynamic>?> fetchQueueStatus({required String clinicId}) async {
    final uri = Uri.parse('$baseUrl/queue?clinic_id=$clinicId');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load queue status: ${response.statusCode}');
      }
    } catch (e) {
      print("API Error Queue: $e");
      return null;
    }
  }

  Future<bool> callNextPatient({required String clinicId}) async {
    final uri = Uri.parse('$baseUrl/queue/next?clinic_id=$clinicId');
    try {
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to call next: ${response.body}");
        return false;
      }
    } catch (e) {
      print("API Error Call Next: $e");
      return false;
    }
  }

  Future<bool> updateTokenStatus({required String appointmentId, required String status}) async {
    final uri = Uri.parse('$baseUrl/queue/status');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointment_id': appointmentId,
          'status': status
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to update status: ${response.body}");
        return false;
      }
    } catch (e) {
      print("API Error Update Status: $e");
      return false;
    }
  }
}
