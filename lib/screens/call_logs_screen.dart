import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class CallLogsScreen extends StatefulWidget {
  final String clinicId;

  const CallLogsScreen({super.key, required this.clinicId});

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  final ApiService _apiService = ApiService();
  List<CallLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _apiService.fetchCallLogs(clinicId: widget.clinicId);
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Call Logs & Insights",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadLogs,
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _logs.isEmpty
                      ? const Center(child: Text("No calls recorded yet."))
                      : Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListView.separated(
                            itemCount: _logs.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: log.wasSuccessful ? Colors.green[100] : Colors.red[100],
                                  child: Icon(
                                    log.wasSuccessful ? Icons.check : Icons.call_end,
                                    color: log.wasSuccessful ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                                title: Text(log.callerPhone, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${DateFormat('MMM d, h:mm a').format(DateTime.parse(log.startTime))} • ${log.durationSeconds}s"),
                                    if (log.transcript != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          log.transcript!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Chip(
                                  label: Text(log.classification, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: Colors.blue[50],
                                  labelStyle: TextStyle(color: Colors.blue[700]),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
