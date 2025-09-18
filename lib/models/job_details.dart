class JobDetails {
  final String id;
  final String customerName;
  final String customerPhone;
  final String vehicle;
  final String plateNumber;
  final String jobDescription;
  final List<String> requestedServices;
  final List<String> assignedParts;
  final List<String> remarks;
  final String status;
  final String timeElapsed;
  final String? customerImage;
  final DateTime createdAt;

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
    this.customerImage,
  });

  static String calculateTimeElapsed(String? startTime, String? endTime) {
    if (startTime == null) return "0m";
    final start = DateTime.parse(startTime);
    final end = endTime != null ? DateTime.parse(endTime) : DateTime.now();
    final diff = end.difference(start);
    return "${diff.inHours}h ${diff.inMinutes % 60}m";
  }
}
