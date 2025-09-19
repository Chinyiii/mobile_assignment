import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_task.dart';
import '../services/supabase_service.dart';

final supabase = Supabase.instance.client;

class ServiceTaskWidget extends StatefulWidget {
  final ServiceTask task;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onComplete;
  final bool isUpdating;
  final String jobStatus; // Add job status parameter

  const ServiceTaskWidget({
    super.key,
    required this.task,
    this.onStart,
    this.onPause,
    this.onComplete,
    this.isUpdating = false,
    required this.jobStatus, // Make it required
  });

  @override
  _ServiceTaskWidgetState createState() => _ServiceTaskWidgetState();
}

class _ServiceTaskWidgetState extends State<ServiceTaskWidget> {
  Timer? _timer;
  late Duration elapsed;
  late ServiceTask currentTask;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  bool _isInternalUpdating = false;
  DateTime? _lastUpdateTime;
  DateTime? _sessionStartTime;

  // Combined updating state from both internal and external sources
  bool get _isUpdating => widget.isUpdating || _isInternalUpdating;

  // Check if task can be started based on job status
  bool get _canStartTask => widget.jobStatus == 'In Progress';

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
    _calculateElapsedTime();
    _setupRealtimeSubscription();

    // Start timer if task is in progress AND job is in progress
    if (currentTask.status == "In Progress" && _canStartTask) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(ServiceTaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update task if it changed from parent
    if (widget.task != oldWidget.task || widget.jobStatus != oldWidget.jobStatus) {
      currentTask = widget.task;
      _calculateElapsedTime();

      // Restart timer if needed and job allows it
      if (currentTask.status == "In Progress" && _canStartTask) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  void _calculateElapsedTime() {
    debugPrint('=== CALCULATING ELAPSED TIME ===');
    debugPrint('Current task status: ${currentTask.status}');
    debugPrint('Current job status: ${widget.jobStatus}');
    debugPrint('Current task duration: ${currentTask.duration}');
    debugPrint('Session start time: ${currentTask.sessionStartTime}');

    int baseDurationSeconds = currentTask.duration;
    debugPrint('Base duration from DB: $baseDurationSeconds seconds');

    if (currentTask.status == "In Progress" && _canStartTask) {
      final now = DateTime.now();
      debugPrint('Current time: $now');

      if (currentTask.sessionStartTime != null) {
        final currentSessionDuration = now.difference(currentTask.sessionStartTime!).inSeconds;
        elapsed = Duration(seconds: baseDurationSeconds + currentSessionDuration);
        _sessionStartTime = currentTask.sessionStartTime;

        debugPrint('Session start time from DB: ${currentTask.sessionStartTime}');
        debugPrint('Current session duration: $currentSessionDuration seconds');
        debugPrint('Total elapsed time: ${elapsed.inSeconds} seconds');
      } else {
        elapsed = Duration(seconds: baseDurationSeconds);
        _sessionStartTime = now;
        debugPrint('No session start time, using stored duration: ${elapsed.inSeconds} seconds');
      }
    } else {
      elapsed = Duration(seconds: baseDurationSeconds);
      _sessionStartTime = null;
      debugPrint('Task not in progress or job not in progress, elapsed: ${elapsed.inSeconds} seconds');
    }

    debugPrint('Final elapsed time: ${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s');
    debugPrint('=== END CALCULATION ===');
  }

  void _setupRealtimeSubscription() {
    try {
      _subscription = supabase
          .from('job_tasks')
          .stream(primaryKey: ['task_id'])
          .eq('task_id', currentTask.taskId)
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
      final newDuration = updated['duration'] != null
          ? _parseDurationFromInterval(updated['duration'])
          : currentTask.duration;
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

      _calculateElapsedTime();

      if (currentTask.status == "In Progress" && _canStartTask) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });

    debugPrint('=== END TASK UPDATE ===');
  }

  int _parseDurationFromInterval(dynamic durationValue) {
    debugPrint('Parsing duration: $durationValue (${durationValue.runtimeType})');

    if (durationValue == null) return 0;

    if (durationValue is int) {
      debugPrint('Duration is int: $durationValue');
      return durationValue;
    }

    String interval = durationValue.toString();
    debugPrint('Duration as string: $interval');

    try {
      if (interval.contains(':')) {
        final parts = interval.split(':');
        if (parts.length >= 3) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final seconds = int.tryParse(parts[2].split('.')[0]) ?? 0;
          final result = hours * 3600 + minutes * 60 + seconds;
          debugPrint('Parsed HH:MM:SS format to $result seconds');
          return result;
        }
      }

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
    if (currentTask.status != "In Progress" || !_canStartTask) return;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && currentTask.status == "In Progress" && _canStartTask) {
        setState(() {
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
    if (_isInternalUpdating) return;

    setState(() {
      _isInternalUpdating = true;
    });

    try {
      await SupabaseService().updateTaskStatus(
        currentTask.taskId,
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
          _isInternalUpdating = false;
        });
      }
    }
  }

  // Internal handlers that can work independently or trigger parent callbacks
  Future<void> _handleStart() async {
    // Check if job allows task to be started
    if (!_canStartTask) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task cannot be started. Job must be "In Progress" first.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    debugPrint('=== INTERNAL PLAY BUTTON PRESSED ===');

    final now = DateTime.now();
    DateTime? startTimeToSet;

    if (currentTask.startTime == null || currentTask.status == "Pending") {
      startTimeToSet = now;
      debugPrint('Setting start_time: $startTimeToSet');
    } else {
      debugPrint('Keeping existing start_time: ${currentTask.startTime}');
    }

    _sessionStartTime = now;
    debugPrint('Setting session start time: $now');

    setState(() {
      currentTask = currentTask.copyWith(
        status: "In Progress",
        startTime: startTimeToSet ?? currentTask.startTime,
        sessionStartTime: now,
      );
      _startTimer();
    });

    await _updateTaskStatus(
      status: "In Progress",
      startTime: startTimeToSet,
      sessionStartTime: now,
    );

    // Trigger parent callback if provided
    widget.onStart?.call();

    debugPrint('=== INTERNAL PLAY COMPLETE ===');
  }

  Future<void> _handlePause() async {
    debugPrint('=== INTERNAL PAUSE BUTTON PRESSED ===');
    debugPrint('Current elapsed: ${elapsed.inSeconds} seconds');

    _stopTimer();

    final totalDuration = elapsed;

    setState(() {
      currentTask = currentTask.copyWith(
        status: "On Hold",
        duration: totalDuration.inSeconds,
        sessionStartTime: null,
      );
    });

    debugPrint('Updating task with duration: ${totalDuration.inSeconds} seconds');

    await _updateTaskStatus(
      status: "On Hold",
      duration: totalDuration,
      sessionStartTime: null,
    );

    // Trigger parent callback if provided
    widget.onPause?.call();

    debugPrint('=== INTERNAL PAUSE COMPLETE ===');
  }

  Future<void> _handleComplete() async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Task'),
          content: Text('Are you sure you want to mark "${currentTask.serviceName}" as completed?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Complete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // Only proceed if user confirmed
    if (confirmed != true) return;

    debugPrint('=== INTERNAL COMPLETE BUTTON PRESSED ===');

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

    // Trigger parent callback if provided
    widget.onComplete?.call();

    debugPrint('=== INTERNAL COMPLETE COMPLETE ===');
  }

  @override
  void dispose() {
    _stopTimer();
    _subscription?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (currentTask.serviceName.isEmpty) {
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
        vertical: 8,
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
                      "Status: ${currentTask.status}",
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
              _formatDuration(elapsed.inSeconds),
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
              if (currentTask.status == "In Progress")
                _buildIconButton(
                    icon: Icons.pause,
                    onPressed: _handlePause
                )
              else
                _buildIconButton(
                    icon: Icons.play_arrow,
                    onPressed: _handleStart,
                    disabled: currentTask.status == 'Completed' || !_canStartTask
                ),
              const SizedBox(width: 4),
              _buildIconButton(
                  icon: Icons.check,
                  onPressed: _handleComplete,
                  disabled: currentTask.status == 'Completed'
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool disabled = false,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFFF2F2F5),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 16,
        icon: Icon(icon, color: disabled ? Colors.grey : Colors.black),
        onPressed: (_isUpdating || disabled) ? null : onPressed,
      ),
    );
  }
}