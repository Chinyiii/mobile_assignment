class ServiceTask {
  final int taskId;
  final String serviceName;
  final String status;
  final int duration;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? sessionStartTime; // Added this field

  ServiceTask({
    required this.taskId,
    required this.serviceName,
    required this.status,
    required this.duration,
    this.startTime,
    this.endTime,
    this.sessionStartTime, // Added this parameter
  });

  factory ServiceTask.fromJson(Map<String, dynamic> json) {
    return ServiceTask(
      taskId: json['task_id'],
      serviceName: json['service_name'],
      status: json['status'],
      duration: json['duration'] ?? 0,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      sessionStartTime: json['session_start_time'] != null
          ? DateTime.parse(json['session_start_time'])
          : null, // Added this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'service_name': serviceName,
      'status': status,
      'duration': duration,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'session_start_time': sessionStartTime?.toIso8601String(), // Added this
    };
  }

  ServiceTask copyWith({
    String? status,
    int? duration,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? sessionStartTime, // Added this parameter
  }) {
    return ServiceTask(
      taskId: taskId,

      serviceName: serviceName,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime, // Added this
    );
  }
}
