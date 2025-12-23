import 'package:flutter/material.dart';
import '../models/models.dart';

class CalendarGrid extends StatelessWidget {
  final List<Appointment> appointments;
  final List<Doctor> doctors;
  final Function(Appointment) onAppointmentTap;
  final int startHour;
  final int endHour;

  const CalendarGrid({
    super.key,
    required this.appointments,
    required this.doctors,
    required this.onAppointmentTap,
    this.startHour = 8,
    this.endHour = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.medical_services_outlined, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                        "No doctors found.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "Add doctors in the backend to see schedule.",
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                ],
            )
        );
    }

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
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            doctor.specialization,
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )),
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
                      for (int i = startHour; i <= endHour; i++) // Extended hours
                        Container(
                          height: 140, // 1 hour = 140px height for better spacing
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

                  // Appointments
                   ...appointments.map((apt) {
                    final doctorIndex = doctors.indexWhere((d) => d.id == apt.doctorId);
                    if (doctorIndex == -1) return const SizedBox.shrink();

                    final timeParts = apt.time.split(':');
                    final hour = int.parse(timeParts[0]);
                    final minute = int.parse(timeParts[1]);
                    
                    final startHour = this.startHour;
                    final hourHeight = 140.0;
                    final offsetPixels = ((hour - startHour) * hourHeight) + ((minute / 60) * hourHeight);
                    final heightPixels = (apt.duration / 60) * hourHeight;
                    
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
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                                            child: InkWell(
                                                onTap: () => onAppointmentTap(apt),
                                                child: Container(
                                                    padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                                    decoration: BoxDecoration(
                                                        color: _getStatusColor(apt.status).withOpacity(0.15),
                                                        border: Border(left: BorderSide(color: _getStatusColor(apt.status), width: 3)),
                                                        borderRadius: BorderRadius.circular(6),
                                                        boxShadow: [
                                                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(2, 2))
                                                        ]
                                                    ),
                                                    child: heightPixels < 40 
                                                        ? Row(
                                                            children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    apt.patientName,
                                                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black87),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                    apt.time,
                                                                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                                                                ),
                                                            ],
                                                        )
                                                        : Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                                Text(
                                                                    apt.patientName,
                                                                    style: const TextStyle(
                                                                        fontWeight: FontWeight.w600, 
                                                                        fontSize: 12, 
                                                                        color: Colors.black87
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                ),
                                                                Text(
                                                                    "${apt.time} • T${apt.tokenNumber} • ${apt.type}",
                                                                    style: const TextStyle(
                                                                        color: Colors.black54, 
                                                                        fontSize: 10
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                ),
                                                            ],
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
    if (status == 'scheduled' || status == 'confirmed') return Colors.purple;
    return Colors.grey;
  }
}
