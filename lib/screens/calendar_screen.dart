import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  final String clinicId;

  const CalendarScreen({super.key, required this.clinicId});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  List<Doctor> _doctors = [];
  String? _selectedDoctorId;
  
  Map<DateTime, List<Appointment>> _appointments = {};
  bool _isLoading = false;

  // Monthly Stats
  int _totalAppointmentsMonth = 0;
  String _busiestDayLabel = "-";
  int _busiestDayCount = 0;
  String _completionRate = "0%";

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadDoctors();
    _loadAppointmentsForMonth(_focusedDay);
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _apiService.fetchDoctors(clinicId: widget.clinicId);
      if (mounted) setState(() => _doctors = doctors);
    } catch (e) {
      print("Error loading doctors: $e");
    }
  }

  Future<void> _loadAppointmentsForMonth(DateTime date) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(end);

    try {
      final appointments = await _apiService.fetchAppointmentsRange(
        startDate: startStr,
        endDate: endStr,
        clinicId: widget.clinicId,
      );

      final Map<DateTime, List<Appointment>> grouped = {};
      int total = 0;
      DateTime? busiestDate;
      int maxCount = 0;
      int completedCount = 0;

      for (var appt in appointments) {
        if (_selectedDoctorId != null && appt.doctorId != _selectedDoctorId) continue;

        DateTime apptDate;
        try {
          if (appt.date.isEmpty) continue; // Skip invalid dates
          apptDate = DateTime.parse(appt.date);
        } catch (e) {
          print("Invalid date format for appointment ${appt.id}: ${appt.date}");
          continue;
        }

        final dateKey = DateTime(apptDate.year, apptDate.month, apptDate.day);
        
        if (grouped[dateKey] == null) grouped[dateKey] = [];
        grouped[dateKey]!.add(appt);
        total++;
        
        if (appt.status.toLowerCase() == 'confirmed' || appt.status.toLowerCase() == 'completed') {
          completedCount++;
        }
      }

      // Calculate stats
      grouped.forEach((key, value) {
        if (value.length > maxCount) {
          maxCount = value.length;
          busiestDate = key;
        }
      });
      
      final completionRate = total > 0 ? ((completedCount / total) * 100).toInt() : 0;

      if (mounted) {
        setState(() {
          _appointments = grouped;
          _totalAppointmentsMonth = total;
          _busiestDayCount = maxCount;
          _busiestDayLabel = busiestDate != null ? DateFormat('MMM d').format(busiestDate!) : "-";
          _completionRate = "$completionRate%";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading appointments: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _appointments[dateKey] ?? [];
  }

  Color _getHeatmapColor(int count) {
    if (count == 0) return Colors.transparent;
    if (count <= 2) return Colors.green.withOpacity(0.2);
    if (count <= 5) return Colors.green.withOpacity(0.5);
    if (count <= 8) return Colors.green.withOpacity(0.8);
    return const Color(0xFF00BFA5); // High traffic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildCalendarSection()),
                Expanded(flex: 1, child: _buildSidePanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const Text("Clinic Performance", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Spacer(),
              _buildDoctorFilter(),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: () { _loadDoctors(); _loadAppointmentsForMonth(_focusedDay); },
                tooltip: "Refresh Data",
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatBadge("Total Appointments", "$_totalAppointmentsMonth", Icons.calendar_today, Colors.blue),
              const SizedBox(width: 24),
              _buildStatBadge("Busiest Day", "$_busiestDayLabel ($_busiestDayCount)", Icons.trending_up, Colors.orange),
              const SizedBox(width: 24),
              _buildStatBadge("Completion Rate", _completionRate, Icons.check_circle, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedDoctorId,
          hint: const Text("All Doctors"),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text("All Doctors")),
            ..._doctors.map((d) => DropdownMenuItem<String?>(value: d.id, child: Text("Dr. ${d.name}"))),
          ],
          onChanged: (value) {
            setState(() => _selectedDoctorId = value);
            _loadAppointmentsForMonth(_focusedDay);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar<Appointment>(
          firstDay: DateTime.utc(2020, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            _loadAppointmentsForMonth(focusedDay);
          },
          eventLoader: _getEventsForDay,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final events = _getEventsForDay(day);
              final color = _getHeatmapColor(events.length);
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: events.isNotEmpty ? Colors.black87 : Colors.black54,
                      fontWeight: events.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              );
            },
            todayBuilder: (context, day, focusedDay) {
               return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
              );
            },
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    final events = _selectedDay != null ? _getEventsForDay(_selectedDay!) : <Appointment>[];
    final walkIns = events.where((e) => e.type == 'Walk-in').length;
    final scheduled = events.length - walkIns;

    return Container(
      margin: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedDay != null ? DateFormat('EEEE, MMM d').format(_selectedDay!) : "Select a Date",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Day Stats
          if (_selectedDay != null) ...[
            Row(
              children: [
                Expanded(child: _buildMiniStat("Walk-ins", "$walkIns", Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildMiniStat("Scheduled", "$scheduled", Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Appointments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
          ],

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : events.isEmpty 
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("No appointments", style: TextStyle(color: Colors.grey[400])),
                      ],
                    ))
                  : ListView.separated(
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final appt = events[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: appt.type == 'Walk-in' ? Colors.purple.shade50 : Colors.blue.shade50,
                            child: Icon(
                              appt.type == 'Walk-in' ? Icons.directions_walk : Icons.calendar_today,
                              color: appt.type == 'Walk-in' ? Colors.purple : Colors.blue,
                              size: 16,
                            ),
                          ),
                          title: Text(appt.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text("${appt.time} • Dr. ${appt.doctorName}", style: const TextStyle(fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: appt.status == 'confirmed' ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              appt.status.toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: appt.status == 'confirmed' ? Colors.green.shade700 : Colors.orange.shade700),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
