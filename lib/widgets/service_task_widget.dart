import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_task.dart';
import '../services/supabase_service.dart';

final supabase = Supabase.instance.client;

class ServiceTaskWidget extends StatefulWidget {
  final ServiceTask task;

  const ServiceTaskWidget({Key? key, required this.task}) : super(key: key);

  @override
  _ServiceTaskWidgetState createState() => _ServiceTaskWidgetState();
}

class _ServiceTaskWidgetState extends State<ServiceTaskWidget> {
  Timer? _timer;
  late Duration elapsed;
  late ServiceTask currentTask;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  bool _isUpdating = false;
  DateTime? _lastUpdateTime;
  DateTime? _sessionStartTime; // Track when current session started

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
    _calculateElapsedTime();
    _setupRealtimeSubscription();

    // Start timer if task is in progress
    if (currentTask.status == "In Progress") {
      _startTimer();
    }
  }

  void _calculateElapsedTime() {
    debugPrint('=== CALCULATING ELAPSED TIME ===');
    debugPrint('Current task status: ${currentTask.status}');
    debugPrint('Current task duration: ${currentTask.duration}');
    debugPrint('Session start time: ${currentTask.sessionStartTime}');

    // Start with the stored duration from database (accumulated time from previous sessions)
    int baseDurationSeconds = currentTask.duration;
    debugPrint('Base duration from DB: $baseDurationSeconds seconds');

    if (currentTask.status == "In Progress") {
      final now = DateTime.now();
      debugPrint('Current time: $now');

      // If we have session_start_time from database, use it
      if (currentTask.sessionStartTime != null) {
        final currentSessionDuration = now.difference(currentTask.sessionStartTime!).inSeconds;
        elapsed = Duration(seconds: baseDurationSeconds + currentSessionDuration);
        _sessionStartTime = currentTask.sessionStartTime;

        debugPrint('Session start time from DB: ${currentTask.sessionStartTime}');
        debugPrint('Current session duration: $currentSessionDuration seconds');
        debugPrint('Total elapsed time: ${elapsed.inSeconds} seconds');
      } else {
        // Fallback: use stored duration and start session now
        elapsed = Duration(seconds: baseDurationSeconds);
        _sessionStartTime = now;
        debugPrint('No session start time, using stored duration: ${elapsed.inSeconds} seconds');
      }
    } else {
      // For paused or completed tasks, use exact stored duration
      elapsed = Duration(seconds: baseDurationSeconds);
      _sessionStartTime = null;
      debugPrint('Task not in progress, elapsed: ${elapsed.inSeconds} seconds');
    }

    debugPrint('Final elapsed time: ${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s');
    debugPrint('=== END CALCULATION ===');
  }

  void _setupRealtimeSubscription() {
    try {
      // Fixed realtime subscription syntax
      _subscription = supabase
          .from('job_tasks')
          .stream(primaryKey: ['task_id'])
          .eq('task_id', currentTask.taskId) // Filter for this specific task
          .listen(
            (event) {
          if (event.isNotEmpty && mounted) {
            final updated = event.first;
            _handleTaskUpdate(updated);
          }
        },
        onError: (error) {
          debugPrint('Realtime subscription error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to setup realtime subscription: $e');
    }
  }

  void _handleTaskUpdate(Map<String, dynamic> updated) {
    debugPrint('=== HANDLING TASK UPDATE ===');
    debugPrint('Update received: $updated');

    final now = DateTime.now();
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!).inMilliseconds < 500) {
      debugPrint('Debouncing update (too recent)');
      return;
    }
    _lastUpdateTime = now;

    if (!mounted) return;

    setState(() {
      final newStatus = updated['status'] as String?;
      final newStartTime = updated['start_time'] != null
          ? DateTime.parse(updated['start_time'])
          : null;

      // Handle interval duration from PostgreSQL
      final newDuration = updated['duration'] != null
          ? _parseDurationFromInterval(updated['duration'])
          : currentTask.duration;

      // Handle session_start_time if available
      final newSessionStartTime = updated['session_start_time'] != null
          ? DateTime.parse(updated['session_start_time'])
          : null;

      debugPrint('New status: $newStatus');
      debugPrint('New duration: $newDuration');
      debugPrint('New session start time: $newSessionStartTime');

      currentTask = currentTask.copyWith(
        status: newStatus ?? currentTask.status,
        startTime: newStartTime,
        duration: newDuration,
        sessionStartTime: newSessionStartTime,
      );

      // Recalculate elapsed time based on updated data
      _calculateElapsedTime();

      // Manage timer based on status
      if (currentTask.status == "In Progress") {
        _startTimer();
      } else {
        _stopTimer();
      }
    });

    debugPrint('=== END TASK UPDATE ===');
  }

  // Helper method to parse PostgreSQL interval to seconds
  int _parseDurationFromInterval(dynamic durationValue) {
    debugPrint('Parsing duration: $durationValue (${durationValue.runtimeType})');

    if (durationValue == null) return 0;

    // If it's already an integer (seconds), return it
    if (durationValue is int) {
      debugPrint('Duration is int: $durationValue');
      return durationValue;
    }

    // If it's a string, try to parse it
    String interval = durationValue.toString();
    debugPrint('Duration as string: $interval');

    try {
      if (interval.contains(':')) {
        // Format: "HH:MM:SS" or "HH:MM:SS.mmm"
        final parts = interval.split(':');
        if (parts.length >= 3) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final seconds = int.tryParse(parts[2].split('.')[0]) ?? 0; // Remove milliseconds
          final result = hours * 3600 + minutes * 60 + seconds;
          debugPrint('Parsed HH:MM:SS format to $result seconds');
          return result;
        }
      }

      // Try parsing as direct number
      final directParse = int.tryParse(interval);
      if (directParse != null) {
        debugPrint('Parsed as direct number: $directParse');
        return directParse;
      }

      debugPrint('Could not parse interval, using current duration: ${currentTask.duration}');
      return currentTask.duration;
    } catch (e) {
      debugPrint('Error parsing interval: $e');
      return currentTask.duration;
    }
  }

  void _startTimer() {
    if (currentTask.status != "In Progress") return;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && currentTask.status == "In Progress") {
        setState(() {
          // Recalculate elapsed time including current session
          if (_sessionStartTime != null) {
            final now = DateTime.now();
            final currentSessionDuration = now.difference(_sessionStartTime!).inSeconds;
            elapsed = Duration(seconds: currentTask.duration + currentSessionDuration);
          } else {
            elapsed += const Duration(seconds: 1);
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _updateTaskStatus({
    required String status,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    DateTime? sessionStartTime,
  }) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await SupabaseService().updateTaskStatus(
        currentTask.taskId.toString(),
        status,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        sessionStartTime: sessionStartTime,
      );
    } catch (e) {
      debugPrint('Failed to update task status: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentTask.taskId == null || currentTask.serviceName.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(
          'Invalid task data',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Row(
        children: [
          // Service Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF2F2F5),
            ),
            child: const Icon(
              Icons.build,
              color: Color(0xFF121417),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Service Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTask.serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF121417),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      "Status: ${currentTask.status ?? 'Unknown'}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (_isUpdating) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Timer Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: const Color(0xFFF2F2F5),
            ),
            child: Text(
              "${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF121417),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Control Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start/Pause button
              currentTask.status == "In Progress"
                  ? Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFFF2F2F5),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.pause),
                  onPressed: _isUpdating ? null : () async {
                    debugPrint('=== PAUSE BUTTON PRESSED ===');
                    debugPrint('Current elapsed: ${elapsed.inSeconds} seconds');

                    _stopTimer();

                    // Store current elapsed time
                    final totalDuration = elapsed;

                    setState(() {
                      currentTask = currentTask.copyWith(
                        status: "On Hold",
                        duration: totalDuration.inSeconds,
                        sessionStartTime: null, // Clear session start time
                      );
                    });

                    debugPrint('Updating task with duration: ${totalDuration.inSeconds} seconds');

                    await _updateTaskStatus(
                      status: "On Hold",
                      duration: totalDuration,
                      sessionStartTime: null, // Clear session start time in DB
                    );

                    debugPrint('=== PAUSE COMPLETE ===');
                  },
                ),
              )
                  : Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFFF2F2F5),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.play_arrow),
                  onPressed: (_isUpdating || currentTask.status == "Completed")
                      ? null
                      : () async {
                    debugPrint('=== PLAY BUTTON PRESSED ===');
                    debugPrint('Current task status: ${currentTask.status}');
                    debugPrint('Current task duration: ${currentTask.duration} seconds');

                    final now = DateTime.now();

                    // Set start_time if it's the very first time starting OR if status was "Pending"
                    DateTime? startTimeToSet;
                    if (currentTask.startTime == null || currentTask.status == "Pending") {
                      startTimeToSet = now;
                      debugPrint('Setting start_time: $startTimeToSet');
                    } else {
                      debugPrint('Keeping existing start_time: ${currentTask.startTime}');
                    }

                    // Always set session start time when resuming
                    _sessionStartTime = now;
                    debugPrint('Setting session start time: $now');

                    setState(() {
                      currentTask = currentTask.copyWith(
                        status: "In Progress",
                        startTime: startTimeToSet ?? currentTask.startTime,
                        sessionStartTime: now, // Track when this session started
                      );
                      _startTimer();
                    });

                    await _updateTaskStatus(
                      status: "In Progress",
                      startTime: startTimeToSet, // Set if first time or was pending
                      sessionStartTime: now, // Always set session start time
                    );

                    debugPrint('=== PLAY COMPLETE ===');
                  },
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFFF2F2F5),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.check),
                  onPressed: (_isUpdating || currentTask.status == "Completed")
                      ? null
                      : () async {
                    _stopTimer();

                    final totalDuration = elapsed;

                    setState(() {
                      currentTask = currentTask.copyWith(
                        status: "Completed",
                        duration: totalDuration.inSeconds,
                      );
                    });

                    await _updateTaskStatus(
                      status: "Completed",
                      endTime: DateTime.now(),
                      duration: totalDuration,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}