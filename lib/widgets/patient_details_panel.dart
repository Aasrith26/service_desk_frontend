import 'package:flutter/material.dart';
import '../models/models.dart';

class PatientDetailsPanel extends StatelessWidget {
  final Appointment? appointment;
  final Doctor? doctor; // Passed from parent
  final VoidCallback onClose;

  const PatientDetailsPanel({
    super.key,
    required this.appointment,
    this.doctor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (appointment == null) {
      return Container(); 
    }

    return Container(
      width: 350,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment!.patientName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Status: ${appointment!.status.toUpperCase()}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _SectionHeader(label: "APPOINTMENT DETAILS", icon: Icons.calendar_today),
                const SizedBox(height: 16),
                _InfoRow(label: "Time", value: "${appointment!.time} (${appointment!.duration} min)"),
                const SizedBox(height: 12),
                _InfoRow(label: "Token", value: "#${appointment!.tokenNumber}", subValue: "Live Sequence"),
                const SizedBox(height: 12),
                _InfoRow(label: "Type", value: appointment!.type),
                const SizedBox(height: 12),
                _InfoRow(
                    label: "Doctor", 
                    value: doctor?.name ?? appointment!.doctorName, 
                    subValue: doctor?.specialization
                ),

                const SizedBox(height: 32),
                _SectionHeader(label: "PATIENT INFORMATION", icon: Icons.person_outline),
                const SizedBox(height: 16),
                
                _ContactCard(
                    icon: Icons.phone_in_talk, 
                    label: "Phone Number", 
                    value: appointment!.patientPhone
                ),
                // Email and History not available in current API
                /*
                const SizedBox(height: 12),
                 _ContactCard(
                    icon: Icons.email_outlined, 
                    label: "Email", 
                    value: "Not available"
                ),
                 const SizedBox(height: 12),
                 _ContactCard(
                    icon: Icons.description_outlined, 
                    label: "Medical History", 
                    value: "None on record",
                    isWarning: false,
                ),
                */
              ],
            ),
          ),

          // Footer Action
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Check In Patient"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5), // Teal color from design
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;

  const _InfoRow({required this.label, required this.value, this.subValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            if (subValue != null)
              Text(subValue!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
    final IconData icon;
    final String label;
    final String value;
    final bool isWarning;

    const _ContactCard({required this.icon, required this.label, required this.value, this.isWarning = false});

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                color: Colors.grey.withOpacity(0.02),
            ),
            child: Row(
                children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: isWarning ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 18, color: isWarning ? Colors.orange[700] : Colors.blue[700]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
}
