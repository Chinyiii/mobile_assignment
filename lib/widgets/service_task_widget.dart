import 'dart:async';
import 'package:flutter/material.dart';
import '../models/service_task.dart';

class ServiceTaskWidget extends StatefulWidget {
  final ServiceTask task;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onComplete;
  final bool isUpdating;

  const ServiceTaskWidget({
    Key? key,
    required this.task,
    required this.onStart,
    required this.onPause,
    required this.onComplete,
    this.isUpdating = false,
  }) : super(key: key);

  @override
  _ServiceTaskWidgetState createState() => _ServiceTaskWidgetState();
}

class _ServiceTaskWidgetState extends State<ServiceTaskWidget> {
  Timer? _timer;
  late int _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.task.duration;
    if (widget.task.status == 'In Progress' && widget.task.sessionStartTime != null) {
      final elapsed = DateTime.now().difference(widget.task.sessionStartTime!).inSeconds;
      _duration += elapsed;
    }
    if (widget.task.status == 'In Progress') {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(ServiceTaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.status != oldWidget.task.status) {
      if (widget.task.status == 'In Progress') {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    }
    if (widget.task.duration != oldWidget.task.duration) {
      setState(() {
        _duration = widget.task.duration;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                  widget.task.serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF121417),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      "Status: ${widget.task.status}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (widget.isUpdating) ...[
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
              _formatDuration(_duration),
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
              if (widget.task.status == "In Progress")
                _buildIconButton(icon: Icons.pause, onPressed: widget.onPause)
              else
                _buildIconButton(icon: Icons.play_arrow, onPressed: widget.onStart, disabled: widget.task.status == 'Completed'),
              const SizedBox(width: 4),
              _buildIconButton(icon: Icons.check, onPressed: widget.onComplete, disabled: widget.task.status == 'Completed'),
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
        onPressed: (widget.isUpdating || disabled) ? null : onPressed,
      ),
    );
  }
}