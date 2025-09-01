class JobDetails {
  final String id;
  final String customerName;
  final String customerPhone;
  final String vehicle;
  final String jobDescription;
  final List<String> requestedServices;
  final List<String> assignedParts;
  final List<String> remarks;
  final String status;
  final String timeElapsed;
  final String? customerImage;

  JobDetails({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.vehicle,
    required this.jobDescription,
    required this.requestedServices,
    required this.assignedParts,
    required this.remarks,
    required this.status,
    required this.timeElapsed,
    this.customerImage,
  });
}
