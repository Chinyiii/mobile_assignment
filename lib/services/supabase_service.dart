import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_assignment/models/job_details.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  Future<List<JobDetails>> getJobDetails() async {
    final response = await supabase
        .from('jobs')
        .select('''
          job_id,
          job_description,
          status,
          start_time,
          end_time,
          created_at,
          users:customer_id ( name, phone_number ),
          vehicles:vehicle_id ( vehicle_name, plate_number ),
          job_services ( services:service_id ( service_name ) ),
          job_parts ( parts:part_id ( part_name ) ),
          remarks ( text, created_at )
        ''');

    final List<JobDetails> jobDetailsList = [];
    for (final job in response) {
      jobDetailsList.add(JobDetails(
        id: job['job_id'].toString(),
        customerName: job['users']['name'],
        customerPhone: job['users']['phone_number'],
        vehicle: job['vehicles']['vehicle_name'],
        jobDescription: job['job_description'],
        requestedServices: (job['job_services'] as List)
            .map((js) => js['services']['service_name'] as String)
            .toList(),
        assignedParts: (job['job_parts'] as List)
            .map((jp) => jp['parts']['part_name'] as String)
            .toList(),
        remarks: (job['remarks'] as List)
            .map((r) => r['text'] as String)
            .toList(),
        status: job['status'],
        timeElapsed: _calculateTimeElapsed(job['start_time'], job['end_time']),
        customerImage: null, // ❌ no such field in DB
      ));
    }

    return jobDetailsList;
  }

  String _calculateTimeElapsed(String? startTime, String? endTime) {
    if (startTime == null) return "0m";
    final start = DateTime.parse(startTime);
    final end = endTime != null ? DateTime.parse(endTime) : DateTime.now();
    final diff = end.difference(start);
    return "${diff.inHours}h ${diff.inMinutes % 60}m";
  }
}
