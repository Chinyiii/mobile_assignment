import 'package:mobile_assignment/models/service_task.dart';

class JobDetails {
  final int id;
  final String customerName;
  final String customerPhone;
  final String vehicle;
  final String plateNumber;
  final String jobDescription;
  final List<ServiceTask> requestedServices;
  final List<String> assignedParts;
  final List<String> remarks;
  final String status;
  final String timeElapsed;
  final DateTime createdAt;
  final String? signatureUrl;

  JobDetails({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.vehicle,
    required this.plateNumber,
    required this.jobDescription,
    required this.requestedServices,
    required this.assignedParts,
    required this.remarks,
    required this.status,
    required this.timeElapsed,
    required this.createdAt,
    this.signatureUrl, // 👈 optional, can be null
  });

  static String calculateTimeElapsed(String? startTime, String? endTime) {
    if (startTime == null) return "0m";
    final start = DateTime.parse(startTime);
    final end = endTime != null ? DateTime.parse(endTime) : DateTime.now();
    final diff = end.difference(start);
    return "${diff.inHours}h ${diff.inMinutes % 60}m";
  }

  factory JobDetails.fromJson(Map<String, dynamic> json) {
    return JobDetails(
      id: json['job_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      vehicle: json['vehicle'],
      plateNumber: json['plate_number'],
      jobDescription: json['job_description'],
      requestedServices: (json['requested_services'] as List<dynamic>)
          .map((e) => ServiceTask.fromJson(e))
          .toList(),
      assignedParts: List<String>.from(json['assigned_parts'] ?? []),
      remarks: List<String>.from(json['remarks'] ?? []),
      status: json['status'],
      timeElapsed: json['time_elapsed'],
      createdAt: DateTime.parse(json['created_at']),
      signatureUrl: json['sign_off_url'],
    );
  }
}
