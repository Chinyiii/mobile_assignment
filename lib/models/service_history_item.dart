class ServiceHistoryItem {
  final int id;
  final String plateNumber;
  final String customerName;
  final String customerPhone;
  final String vehicle;
  final DateTime serviceDate;
  final String serviceType;
  final String status;
  final String timeElapsed;
  final String jobDescription;
  final List<String> requestedServices;
  final List<String> assignedParts;
  final List<String> remarks;
  final List<String> photos;

  ServiceHistoryItem({
    required this.id,
    required this.plateNumber,
    required this.customerName,
    required this.customerPhone,
    required this.vehicle,
    required this.serviceDate,
    required this.serviceType,
    required this.status,
    required this.timeElapsed,
    required this.jobDescription,
    required this.requestedServices,
    required this.assignedParts,
    required this.remarks,
    required this.photos,
  });
}
