enum JobStatus { assigned, inProgress, completed }

class Job {
  final String id;
  final String title;
  final String vehicle;
  final JobStatus status;
  final DateTime date;
  final String? iconPath;

  Job({
    required this.id,
    required this.title,
    required this.vehicle,
    required this.status,
    required this.date,
    this.iconPath,
  });

  String get statusText {
    switch (status) {
      case JobStatus.assigned:
        return 'Assigned';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
    }
  }

  String get dateText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jobDate = DateTime(date.year, date.month, date.day);

    if (jobDate == today) {
      return 'Today';
    } else if (jobDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
