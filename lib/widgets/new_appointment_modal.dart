import 'package:flutter/material.dart';
import '../models/models.dart';

class NewAppointmentDialog extends StatefulWidget {
  final Function(String patientName, String patientPhone, String doctorId, TimeOfDay time, String type, String notes) onSubmit;
  final DateTime selectedDate;
  final List<Doctor> doctors;

  const NewAppointmentDialog({
    super.key,
    required this.onSubmit,
    required this.selectedDate,
    required this.doctors,
  });

  @override
  State<NewAppointmentDialog> createState() => _NewAppointmentDialogState();
}

class _NewAppointmentDialogState extends State<NewAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  String _patientName = '';
  String _patientPhone = ''; // Added phone
  String? _doctorId;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String _type = 'Consultation';
  String _notes = '';

  @override
  void initState() {
    super.initState();
    if (widget.doctors.isNotEmpty) {
      _doctorId = widget.doctors.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doctors.isEmpty) {
        return const Center(child: Text("No doctors available"));
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "New Appointment",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scrollable Form Content
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient Name
                        _Label("Patient Name", Icons.person_outline),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: _inputDecoration("e.g. John Doe"),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please enter a name' : null,
                          onSaved: (value) => _patientName = value!,
                        ),
                        const SizedBox(height: 16),
                        
                        // Patient Phone
                        _Label("Phone Number", Icons.phone),
                        const SizedBox(height: 8),
                         TextFormField(
                          decoration: _inputDecoration("e.g. 555-123-4567"),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please enter phone number' : null,
                          onSaved: (value) => _patientPhone = value!,
                        ),

                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Doctor Selection
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Label("Doctor", Icons.medical_services_outlined),
                                   const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _doctorId,
                                    decoration: _inputDecoration("Select Doctor"),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    borderRadius: BorderRadius.circular(16),
                                    items: widget.doctors.map((doc) {
                                      return DropdownMenuItem(
                                        value: doc.id,
                                        child: Text(doc.name, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                       setState(() {
                                         _doctorId = value!;
                                       });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Time Selection
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   _Label("Time", Icons.access_time),
                                   const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: _time,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _time = picked;
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: InputDecorator(
                                      decoration: _inputDecoration(""),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_time.format(context)),
                                          const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Appointment Type
                         _Label("Appointment Type", Icons.calendar_today_outlined),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: ['Consultation', 'Follow-up', 'Check-up'].map((type) {
                            final isSelected = _type == type;
                            return InkWell(
                              onTap: () {
                                  setState(() { _type = type; });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF00BFA5).withOpacity(0.1) : Colors.white,
                                      border: Border.all(
                                          color: isSelected ? const Color(0xFF00BFA5) : Colors.grey.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                      type,
                                      style: TextStyle(
                                          color: isSelected ? const Color(0xFF00BFA5) : Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                      ),
                                  ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Notes
                        _Label("Notes (Optional)", Icons.edit_outlined),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: _inputDecoration("Reason for visit..."),
                          maxLines: 3,
                          onSaved: (value) => _notes = value ?? '',
                        ),
                         const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Actions
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Confirm Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
      return InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: Color(0xFF00BFA5), width: 2),
          ),
      );
  }

  Widget _Label(String text, IconData icon) {
      return Row(
          children: [
              Icon(icon, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                  text,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                  ),
              ),
          ],
      );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Pass raw data back to MainScreen to handle API
      widget.onSubmit(
          _patientName,
          _patientPhone,
          _doctorId!,
          widget.selectedDate == DateTime.now() ? _time : _time, // Time logic simplified
          _type,
          _notes
      );
      Navigator.of(context).pop();
    }
  }
}

Future<void> showNewAppointmentDialog(
    BuildContext context, 
    Function(String, String, String, TimeOfDay, String, String) onSubmit, 
    DateTime selectedDate,
    List<Doctor> doctors) {
  return showDialog(
    context: context,
    builder: (context) => NewAppointmentDialog(
        onSubmit: onSubmit, 
        selectedDate: selectedDate,
        doctors: doctors
    ),
  );
}
