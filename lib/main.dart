import 'dart:async';
import 'package:flutter/material.dart';
import 'layout/dashboard_layout.dart';
import 'services/api_service.dart';
import 'models/models.dart';
import 'widgets/new_appointment_modal.dart';
import 'widgets/stats_card.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/patient_details_panel.dart';
import 'widgets/sidebar.dart';
import 'screens/login_screen.dart';
import 'screens/call_logs_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/queue_management_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare Command Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFA5), // Teal primary
          background: const Color(0xFFF5F7FA),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Inter',
      ),
      home: const LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final String userName;

  const MainScreen({
    super.key, 
    required this.clinicId,
    required this.clinicName, 
    required this.userName
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  
  int _selectedIndex = 0; // 0 = Dashboard, 1 = Call Logs

  List<Appointment> _appointments = [];
  List<Doctor> _doctors = [];
  List<ClinicSession> _sessions = [];
  List<StatCardData> _stats = [];
  
  Appointment? _selectedAppointment;
  Timer? _refreshTimer; // Timer for polling
  
  // Date State
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  
  bool _isLoading = true;
  bool _isFetching = false; // Prevent overlapping requests

  @override
  void initState() {
    super.initState();
    _loadData();
    // Start polling every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) _loadData(silent: true);
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (_isFetching) return; // Skip if already fetching
    _isFetching = true;

    if (!silent) {
        setState(() => _isLoading = true);
    }
    
    try {
      final clinicId = widget.clinicId; // Use passed ID
      
      final statsFuture = _apiService.fetchStats(clinicId: clinicId);
      final doctorsFuture = _apiService.fetchDoctors(clinicId: clinicId);
      final sessionFuture = _apiService.fetchSessions(clinicId: clinicId);
      
      final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final apptFuture = _apiService.fetchAppointments(date: dateStr); 
      
      final results = await Future.wait([statsFuture, doctorsFuture, apptFuture, sessionFuture]);
      
      if (mounted) {
        setState(() {
          _stats = results[0] as List<StatCardData>;
          _doctors = results[1] as List<Doctor>;
          
          // Filter appointments locally by clinic doctors if API doesn't filter
          final allAppointments = results[2] as List<Appointment>;
          // Simple filter: Only show if doctor is in our doctor list (or no doctor assigned)
          _appointments = allAppointments.where((appt) {
             if (appt.doctorId == null) return true; // Unassigned
             return _doctors.any((d) => d.id == appt.doctorId);
          }).toList();

          _sessions = results[3] as List<ClinicSession>;
           
           _isLoading = false;
        });
      }
    } catch (e) {
      if (!silent) print("Error loading data: $e");
      if (mounted && !silent) {
        setState(() => _isLoading = false);
        // Show friendly error message
        String message = "Failed to connect to server.";
        if (e.toString().contains("Connection refused") || e.toString().contains("ClientException")) {
            message = "Backend server is unreachable. Please ensure server.py is running.";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(label: 'Retry', onPressed: _loadData, textColor: Colors.white),
            )
        );
      }
    } finally {
        _isFetching = false;
    }
  }



  // Helper to check if two dates are same day
  bool _isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onAppointmentTap(Appointment apt) {
    setState(() {
      _selectedAppointment = apt;
    });
  }

  void _closePanel() {
    setState(() {
      _selectedAppointment = null;
    });
  }
  
  Future<void> _pickDate() async {
      final picked = await showDatePicker(
          context: context, 
          initialDate: _selectedDate, 
          firstDate: DateTime(2024), 
          lastDate: DateTime(2026),
          builder: (context, child) {
              return Theme(
                  data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: Color(0xFF00BFA5)),
                  ),
                  child: child!,
              );
          }
      );
      if (picked != null && !_isSameDay(picked, _selectedDate)) {
          setState(() {
              _selectedDate = picked;
          });
          _loadData(); // Reload data for new date
      }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: _selectedIndex == 0 
          ? _buildDashboardContent() 
          : _selectedIndex == 1 
              ? CallLogsScreen(clinicId: widget.clinicId)
              : _selectedIndex == 2
                  ? CalendarScreen(clinicId: widget.clinicId)
                  : QueueManagementScreen(clinicId: widget.clinicId),
    );
  }

  Widget _buildDashboardContent() {
    // Filter locally by search query if needed
    final filteredAppointments = _appointments.where((apt) {
      if (_searchQuery.isEmpty) return true;
      final queryLower = _searchQuery.toLowerCase();
      // We don't have doctor object lookup here easily without map, 
      // but Appointment model has doctorName/patientName.
      return apt.patientName.toLowerCase().contains(queryLower) ||
             apt.doctorName.toLowerCase().contains(queryLower) ||
             apt.type.toLowerCase().contains(queryLower);
    }).toList();
    
    // Calculate breakdown
    final totalAppts = filteredAppointments.length;
    final walkinsAppts = filteredAppointments.where((a) => a.type == 'Walk-in').length;
    final aiAppts = totalAppts - walkinsAppts;
    
    // Get Stats safely
    String dailyCalls = "0";
    String dailyCallsTrend = "";
    
    if (_stats.isNotEmpty) {
        // Find by label
        final callsStat = _stats.firstWhere((s) => s.label == "Incoming Calls", 
            orElse: () => StatCardData(label: "", value: "0", icon: "", color: ""));
        dailyCalls = callsStat.value;
        dailyCallsTrend = callsStat.trend ?? "";
    }
    
    final dateString = "${_weekDay(_selectedDate.weekday)}, ${_month(_selectedDate.month)} ${_selectedDate.day}";

    if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dashboard",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                            InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Text(
                                              "$dateString • ${widget.clinicName}", 
                                              style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.logout, size: 16, color: Colors.grey),
                                        ],
                                    ),
                                ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Hello, ${widget.userName}", // Display user name
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5)),
                            )
                          ],
                        ),
                        const Spacer(),
                        
                        // Search Bar
                        Container(
                          width: 300,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey[400]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Search patients, doctors...",
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Notification
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),

                        // Add Button
                        ElevatedButton.icon(
                          onPressed: () => showNewAppointmentDialog(context, _handleAddAppointment, _selectedDate, _doctors),
                          icon: const Icon(Icons.add),
                          label: const Text("New Appointment"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            // Stats Row
                            Row(
                            children: [
                              Expanded(
                                child: StatsCard(
                                  icon: Icons.phone_in_talk,
                                  iconColor: Colors.blue,
                                  label: "Incoming Calls",
                                  value: dailyCalls,
                                  trend: dailyCallsTrend,
                                  isPositive: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: StatsCard(
                                  icon: Icons.calendar_today,
                                  iconColor: const Color(0xFF00BFA5),
                                  label: "Appointments",
                                  value: "$totalAppts",
                                  subtext: "AI: $aiAppts • Walk-in: $walkinsAppts", // Breakdown
                                ),
                              ),
                              const SizedBox(width: 24),
                              const Expanded(
                                flex: 2, 
                                child: _AiReceptionistCard(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Calendar
                          Builder(
                            builder: (context) {
                                final sessionInfo = _getDisplayHours();
                                final status = sessionInfo['status'] as String;
                                final name = sessionInfo['name'] as String;
                                int startH = sessionInfo['start'] as int;
                                int endH = sessionInfo['end'] as int;
                                
                                final dateStr = "${_weekDay(_selectedDate.weekday)}, ${_month(_selectedDate.month)} ${_selectedDate.day}";
                                
                                return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        if (status != 'Active' && status != 'Default')
                                            Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.only(bottom: 16),
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                decoration: BoxDecoration(
                                                    color: Colors.amber[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.amber[300]!)
                                                ),
                                                child: Row(
                                                    children: [
                                                        const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                            status == 'Upcoming' 
                                                                ? "Upcoming: $name Session starts at ${startH.toString().padLeft(2, '0')}:00 ($dateStr)"
                                                                : "Clinic Closed. Viewing: $name Session ($dateStr)",
                                                            style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.w500),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        
                                        SizedBox(
                                            height: 600, 
                                            child: CalendarGrid(
                                              appointments: filteredAppointments,
                                              doctors: _doctors,
                                              onAppointmentTap: _onAppointmentTap,
                                              startHour: startH,
                                              endHour: endH,
                                            ),
                                        ),
                                    ]
                                );
                            }
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Scrim
        if (_selectedAppointment != null)
           Positioned.fill(
             child: GestureDetector(
               onTap: _closePanel,
               behavior: HitTestBehavior.opaque,
               child: Container(color: Colors.transparent),
             ),
           ),

        // Side Panel
        if (_selectedAppointment != null)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                   BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(-5, 0)),
                ],
              ),
              child: PatientDetailsPanel(
                appointment: _selectedAppointment,
                doctor: _findDoctor(_selectedAppointment!.doctorId),
                onClose: _closePanel,
              ),
            ),
          ),
      ],
    );
  }

  Doctor? _findDoctor(String id) {
      try {
          return _doctors.firstWhere((d) => d.id == id);
      } catch (e) {
          return null;
      }
  }



  // Returns {'start': int, 'end': int, 'status': String, 'name': String}
  Map<String, dynamic> _getDisplayHours() {
      // Default fallback
      int start = 8; 
      int end = 20;
      
      if (_sessions.isEmpty) return {'start': start, 'end': end, 'status': 'Default', 'name': ''};
      
      // Sort sessions by time
      _sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      // Get first session start/end as a safe default for "Non-Active" times
      int firstStart = int.parse(_sessions.first.startTime.split(':')[0]);
      int firstEnd = int.parse(_sessions.first.endTime.split(':')[0]);
      String firstName = _sessions.first.name;
      
      final now = DateTime.now();
      final currentHour = now.hour;
      
      try {
          // 1. Check for Active Session
          for (var s in _sessions) {
              int sStart = int.parse(s.startTime.split(':')[0]);
              int sEnd = int.parse(s.endTime.split(':')[0]);
              
              if (currentHour >= sStart && currentHour < sEnd) {
                  return {'start': sStart, 'end': sEnd, 'status': 'Active', 'name': s.name};
              }
          }
          
          // 2. Check for Upcoming Session (Next one today)
          for (var s in _sessions) {
              int sStart = int.parse(s.startTime.split(':')[0]);
              int sEnd = int.parse(s.endTime.split(':')[0]);
              
              if (sStart > currentHour) {
                  return {'start': sStart, 'end': sEnd, 'status': 'Upcoming', 'name': s.name};
              }
          }
          
          // 3. Late Night / Past all sessions -> Show First Session
          return {'start': firstStart, 'end': firstEnd, 'status': 'Closed', 'name': firstName};

      } catch (e) {
          print("Error parsing session times: $e");
          return {'start': start, 'end': end, 'status': 'Error', 'name': ''};
      }
  }
  
  Future<void> _handleAddAppointment(String patientName, String patientPhone, String doctorId, TimeOfDay time, String type, String notes) async {
      // Use the known clinic ID from login
      String clinicId = widget.clinicId;
      
      final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

      String? error = await _apiService.createAppointment(
          clinicId: clinicId,
          doctorId: doctorId,
          patientName: patientName,
          patientPhone: patientPhone,
          date: dateStr,
          time: timeStr
      );
          
      if (mounted) {
          if (error == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Scheduled!'), backgroundColor: Colors.green));
              _loadData();
          } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
          }
      }
  }

  String _weekDay(int day) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[day - 1];
  }
  
  String _month(int month) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[month - 1];
  }
}

class _AiReceptionistCard extends StatelessWidget {
  const _AiReceptionistCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFA5).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
           Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.phone_callback, size: 100, color: Colors.white.withOpacity(0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "AI Receptionist Live",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Active and handling calls.",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              Container(
                height: 6,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 140, // Mock progress
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
