import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class QueueManagementScreen extends StatefulWidget {
  final String clinicId;

  const QueueManagementScreen({super.key, required this.clinicId});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  final ApiService _apiService = ApiService();
  Timer? _refreshTimer;
  bool _isLoading = true;

  // Queue Data
  Appointment? _servingToken;
  List<Appointment> _waitingList = [];
  List<Appointment> _skippedList = [];

  @override
  void initState() {
    super.initState();
    _loadQueueData();
    // Poll every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _loadQueueData(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQueueData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final data = await _apiService.fetchQueueStatus(clinicId: widget.clinicId);
      if (data != null && mounted) {
        setState(() {
          // Parse Serving
          if (data['current_token'] != null) {
            _servingToken = Appointment.fromJson(data['current_token']);
          } else {
            _servingToken = null;
          }

          // Parse Waiting
          if (data['waiting'] != null) {
            _waitingList = (data['waiting'] as List)
                .map((item) => Appointment.fromJson(item))
                .toList();
          } else {
            _waitingList = [];
          }

          // Parse Skipped
          if (data['skipped'] != null) {
            _skippedList = (data['skipped'] as List)
                .map((item) => Appointment.fromJson(item))
                .toList();
          } else {
            _skippedList = [];
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading queue: $e");
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _callNext() async {
    final success = await _apiService.callNextPatient(clinicId: widget.clinicId);
    if (success) {
      _loadQueueData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Called next patient"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to call next"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateStatus(String appointmentId, String status) async {
    final success = await _apiService.updateTokenStatus(
        appointmentId: appointmentId, status: status);
    if (success) {
      _loadQueueData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Marked as $status"), backgroundColor: Colors.blue),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Queue Management",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Text(
            "Manage patient flow and tokens",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Now Serving & Controls
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildNowServingCard(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
                const SizedBox(width: 32),

                // Right Column: Lists
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildListSection("Waiting List", _waitingList, isWaiting: true)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildListSection("Skipped / Late", _skippedList, isSkipped: true)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowServingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            "NOW SERVING",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF00BFA5),
            ),
          ),
          const SizedBox(height: 24),
          if (_servingToken != null) ...[
            Text(
              "#${_servingToken!.tokenNumber}",
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _servingToken!.patientName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _servingToken!.type,
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
              ),
            ),
          ] else ...[
            const Icon(Icons.free_breakfast_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No active patient",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _callNext,
            icon: const Icon(Icons.notifications_active),
            label: const Text("CALL NEXT PATIENT"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          if (_servingToken != null) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(_servingToken!.id, "VISITED"),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Mark Visited"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(_servingToken!.id, "NO_SHOW"),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text("No Show"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<Appointment> list, {bool isWaiting = false, bool isSkipped = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isWaiting ? Icons.people_outline : Icons.timer_off_outlined,
                  color: isWaiting ? Colors.blue : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "$title (${list.length})",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      "Empty",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final apt = list[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isWaiting ? Colors.blue[100] : Colors.orange[100],
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${apt.tokenNumber}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isWaiting ? Colors.blue[800] : Colors.orange[800],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apt.patientName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    apt.time,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            if (isWaiting)
                              IconButton(
                                icon: const Icon(Icons.skip_next, color: Colors.orange),
                                tooltip: "Skip (Late)",
                                onPressed: () => _updateStatus(apt.id, "SKIPPED"),
                              ),
                            if (isSkipped)
                              IconButton(
                                icon: const Icon(Icons.undo, color: Colors.blue),
                                tooltip: "Add back to Queue",
                                onPressed: () => _updateStatus(apt.id, "BOOKED"),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
