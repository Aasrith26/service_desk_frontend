import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  final String clinicId;

  const AdminSettingsScreen({super.key, required this.clinicId});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;

  // Clinic Settings
  String _clinicName = '';
  int _rushLowThreshold = 3;
  int _rushMediumThreshold = 7;
  int _avgConsultationMinutes = 10;

  // Session Config
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settingsData = await _apiService.fetchClinicSettings(clinicId: widget.clinicId);
      final sessionsData = await _apiService.fetchSessionsConfig(clinicId: widget.clinicId);
      
      if (mounted) {
        setState(() {
          if (settingsData != null) {
            _clinicName = settingsData['clinic_name'] ?? '';
            _rushLowThreshold = settingsData['rush_low_threshold'] ?? 3;
            _rushMediumThreshold = settingsData['rush_medium_threshold'] ?? 7;
            _avgConsultationMinutes = settingsData['average_consultation_minutes'] ?? 10;
          }
          
          if (sessionsData != null && sessionsData['sessions'] != null) {
            _sessions = List<Map<String, dynamic>>.from(sessionsData['sessions']);
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading settings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    final result = await _apiService.updateClinicSettings(
      clinicId: widget.clinicId,
      rushLowThreshold: _rushLowThreshold,
      rushMediumThreshold: _rushMediumThreshold,
      avgConsultationMinutes: _avgConsultationMinutes,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Settings saved"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save settings"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateSession(String sessionId, Map<String, dynamic> updates) async {
    final result = await _apiService.updateSession(
      sessionId: sessionId,
      startTime: updates['start_time'],
      endTime: updates['end_time'],
      maxTokens: updates['max_tokens'],
      bufferMinutes: updates['buffer_minutes'],
      isActive: updates['is_active'],
    );
    
    if (mounted) {
      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Session updated"), backgroundColor: Colors.green),
        );
        _loadSettings(); // Reload
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update session"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Settings",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              _clinicName.isNotEmpty ? _clinicName : "Clinic Configuration",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Rush Thresholds Card
            _buildCard(
              title: "Rush Level Thresholds",
              icon: Icons.speed,
              child: Column(
                children: [
                  _buildNumberField(
                    label: "Low threshold (patients)",
                    value: _rushLowThreshold,
                    onChanged: (v) => setState(() => _rushLowThreshold = v),
                    helperText: "Rush is Low when waiting ≤ this",
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    label: "Medium threshold (patients)",
                    value: _rushMediumThreshold,
                    onChanged: (v) => setState(() => _rushMediumThreshold = v),
                    helperText: "Rush is High when waiting > this",
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    label: "Avg consultation time (minutes)",
                    value: _avgConsultationMinutes,
                    onChanged: (v) => setState(() => _avgConsultationMinutes = v),
                    helperText: "Used to estimate wait time",
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Save Settings"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sessions Config Card
            _buildCard(
              title: "Session Configuration",
              icon: Icons.schedule,
              child: Column(
                children: _sessions.isEmpty
                  ? [const Text("No sessions configured")]
                  : _sessions.map((session) => _buildSessionRow(session)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00BFA5), size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required Function(int) onChanged,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              color: Colors.grey[600],
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$value",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
              color: const Color(0xFF00BFA5),
            ),
            if (helperText != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  helperText,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSessionRow(Map<String, dynamic> session) {
    final String sessionId = session['id'] ?? '';
    final String name = session['name'] ?? 'Session';
    final String startTime = session['start_time'] ?? '09:00';
    final String endTime = session['end_time'] ?? '13:00';
    final int maxTokens = session['max_tokens'] ?? 20;
    final bool isActive = session['is_active'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Session Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.green[800] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Time
          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text("$startTime - $endTime", style: TextStyle(color: Colors.grey[700])),
          const SizedBox(width: 16),
          
          // Max Tokens
          Icon(Icons.people, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text("$maxTokens tokens", style: TextStyle(color: Colors.grey[700])),
          
          const Spacer(),
          
          // Active Toggle
          Switch(
            value: isActive,
            onChanged: (value) {
              _updateSession(sessionId, {'is_active': value});
            },
            activeColor: const Color(0xFF00BFA5),
          ),
          
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditSessionDialog(session),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  void _showEditSessionDialog(Map<String, dynamic> session) {
    final String sessionId = session['id'] ?? '';
    String startTime = session['start_time'] ?? '09:00';
    String endTime = session['end_time'] ?? '13:00';
    int maxTokens = session['max_tokens'] ?? 20;
    int bufferMinutes = session['buffer_minutes'] ?? 10;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Edit ${session['name']} Session"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start Time
              ListTile(
                title: const Text("Start Time"),
                trailing: Text(startTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(startTime.split(':')[0]),
                      minute: int.parse(startTime.split(':')[1]),
                    ),
                  );
                  if (time != null) {
                    setDialogState(() {
                      startTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                    });
                  }
                },
              ),
              // End Time
              ListTile(
                title: const Text("End Time"),
                trailing: Text(endTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(endTime.split(':')[0]),
                      minute: int.parse(endTime.split(':')[1]),
                    ),
                  );
                  if (time != null) {
                    setDialogState(() {
                      endTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                    });
                  }
                },
              ),
              const Divider(),
              // Max Tokens
              Row(
                children: [
                  const Text("Max Tokens"),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: maxTokens > 1 ? () => setDialogState(() => maxTokens--) : null,
                  ),
                  Text("$maxTokens", style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setDialogState(() => maxTokens++),
                  ),
                ],
              ),
              // Buffer Minutes
              Row(
                children: [
                  const Text("Buffer (mins)"),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: bufferMinutes > 0 ? () => setDialogState(() => bufferMinutes--) : null,
                  ),
                  Text("$bufferMinutes", style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setDialogState(() => bufferMinutes++),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateSession(sessionId, {
                  'start_time': startTime,
                  'end_time': endTime,
                  'max_tokens': maxTokens,
                  'buffer_minutes': bufferMinutes,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
