import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class CalendarGrid extends StatelessWidget {
  final List<Appointment> appointments;
  final Function(Appointment) onAppointmentTap;

  const CalendarGrid({
    super.key,
    required this.appointments,
    required this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Header Row (Doctors)
          Container(
            padding: const EdgeInsets.only(left: 60, top: 16, bottom: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: Row(
              children: doctors.map((doctor) {
                return Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(int.parse(doctor.color)),
                        child: Text(
                          doctor.avatar,
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            doctor.specialty,
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Grid Body
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  // Grid Lines & Time Labels
                  Column(
                    children: [
                      for (int i = 8; i <= 17; i++)
                        Container(
                          height: 100, // 1 hour = 100px height
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.withOpacity(0.05)),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Center(
                                  child: Text(
                                    "${i > 12 ? i - 12 : i} ${i >= 12 ? 'PM' : 'AM'}",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // Vertical Lines for Doctors
                              ...List.generate(
                                doctors.length,
                                (index) => Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(color: Colors.grey.withOpacity(0.05)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Current Time Line (Mocked at 10 AM)
                  Positioned(
                    top: 200, // 10:00 AM (8am start + 2 hours * 100px)
                    left: 60,
                    right: 0,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                   Positioned(
                    top: 194, // Centered on line
                    left: 10,
                    child: const Text(
                      "Current Time",
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),



                  
                  // Re-implementing Appointments with FractionallySizedBox for stability
                   ...appointments.map((apt) {
                   final doctorIndex = doctors.indexWhere((d) => d.id == apt.doctorId);
                    if (doctorIndex == -1) return const SizedBox.shrink();

                    final timeParts = apt.time.split(':');
                    final hour = int.parse(timeParts[0]);
                    final minute = int.parse(timeParts[1]);
                    
                    final startHour = 8;
                    final offsetPixels = ((hour - startHour) * 100) + ((minute / 60) * 100);
                    final heightPixels = (apt.duration / 60) * 100;
                    
                    // Width of one column is 1/3 (since 3 doctors). 
                    // Left offset is (1/3 * index).
                    // We need to account for the 60px time label width.
                    // This is tricky in a Stack. 
                    // Let's try correct Layout structure: Row of Stacks?
                    return Positioned(
                        top: offsetPixels,
                        left: 60, 
                        right: 0,
                        height: heightPixels,
                        child: Row(
                            children: List.generate(doctors.length, (idx) {
                                if (idx == doctorIndex) {
                                    return Expanded(
                                        child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: InkWell(
                                                onTap: () => onAppointmentTap(apt),
                                                child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                        color: _getStatusColor(apt.status).withOpacity(0.15),
                                                        border: Border(left: BorderSide(color: _getStatusColor(apt.status), width: 4)),
                                                        borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: SingleChildScrollView(
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                                Text(
                                                                    getPatient(apt.patientId).name,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold, 
                                                                        fontSize: 11, // Reduced font
                                                                        color: Colors.black87
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                ),
                                                                if (heightPixels > 30) // Only show time if enough space
                                                                Text(
                                                                    "${apt.time}",
                                                                    style: TextStyle(
                                                                        color: Colors.black54, 
                                                                        fontSize: 9
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    );
                                }
                                return const Expanded(child: SizedBox());
                            }),
                        ),
                    );

                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'checked-in') return Colors.green;
    if (status == 'waiting') return Colors.orange;
    if (status == 'in-progress') return Colors.blue;
    if (status == 'scheduled') return Colors.purple;
    return Colors.grey;
  }
}
