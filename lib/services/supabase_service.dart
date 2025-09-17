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
        plateNumber: job['vehicles']['plate_number'],
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
        timeElapsed: JobDetails.calculateTimeElapsed(job['start_time'], job['end_time']),
        customerImage: null, // ❌ no such field in DB
      ));
    }

    return jobDetailsList;
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await supabase
        .from('jobs')
        .update({'status': status})
        .eq('job_id', jobId);
  }
}
