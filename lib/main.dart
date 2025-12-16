import 'package:flutter/material.dart';
import 'layout/dashboard_layout.dart';
import 'data/mock_data.dart';
import 'widgets/new_appointment_modal.dart';
import 'widgets/stats_card.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/patient_details_panel.dart';

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
        fontFamily: 'Inter', // Assuming Inter is available or fallback
      ),
      home: const DashboardLayout(child: MainScreen()),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Appointment> _appointments = List.from(initialAppointments);
  Appointment? _selectedAppointment;
  
  // Date State
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  void _addAppointment(Appointment appointment) {
    setState(() {
      _appointments.add(appointment);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment for ${getPatient(appointment.patientId).name} scheduled!')),
    );
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
      if (picked != null && picked != _selectedDate) {
          setState(() {
              _selectedDate = picked;
          });
      }
  }

  @override
  Widget build(BuildContext context) {
    // Filter appointments based on search query AND date
    final filteredAppointments = _appointments.where((apt) {
      if (!_isSameDay(apt.date, _selectedDate)) return false;
      
      if (_searchQuery.isEmpty) return true;
      final patient = getPatient(apt.patientId);
      final doctor = getDoctor(apt.doctorId);
      final queryLower = _searchQuery.toLowerCase();
      return patient.name.toLowerCase().contains(queryLower) ||
             doctor.name.toLowerCase().contains(queryLower) ||
             apt.type.toLowerCase().contains(queryLower);
    }).toList();
    
    // Filter Calls
    final dailyCalls = mockCalls.where((c) => _isSameDay(c.date, _selectedDate)).length;
    final totalSlots = 80; // 8 hrs * 10 slots roughly
    final availableSlots = totalSlots - filteredAppointments.length;
    
    // Format Date String
    final dateString = "${_weekDay(_selectedDate.weekday)}, ${_month(_selectedDate.month)} ${_selectedDate.day}";

    return Stack(
      children: [
        // Main Content Area
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
                              "Command Center",
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
                                              "$dateString • Good Morning, Sarah",
                                              style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[500]),
                                        ],
                                    ),
                                ),
                            ),
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
                          onPressed: () => showNewAppointmentDialog(context, _addAppointment, _selectedDate),
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
                                  value: "$dailyCalls",
                                  trend: dailyCalls > 20 ? "+12% vs last hr" : "Normal Volume",
                                  isPositive: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: StatsCard(
                                  icon: Icons.calendar_today,
                                  iconColor: const Color(0xFF00BFA5),
                                  label: "Appointments",
                                  value: "${filteredAppointments.length}",
                                  subtext: "$availableSlots slots left",
                                ),
                              ),
                              const SizedBox(width: 24),
                              const Expanded(
                                flex: 2, // Wider card for AI Receptionist
                                child: _AiReceptionistCard(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Calendar
                          SizedBox(
                            height: 600, // Fixed height for scrolling internally
                            child: CalendarGrid(
                              appointments: filteredAppointments,
                              onAppointmentTap: _onAppointmentTap,
                            ),
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

        // Scrim (Click to close panel)
        if (_selectedAppointment != null)
           Positioned.fill(
             child: GestureDetector(
               onTap: _closePanel,
               behavior: HitTestBehavior.opaque,
               child: Container(color: Colors.transparent),
             ),
           ),

        // Side Panel (Overlay)
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
                onClose: _closePanel,
              ),
            ),
          ),
      ],
    );
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
                "Handling 3 calls and 2 chats.",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              // Progress bar visual
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
                    width: 140,
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
