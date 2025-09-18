import 'package:mobile_assignment/models/service_history_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_assignment/models/job_details.dart';

import '../models/service_task.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  //Chinyi
  Future<List<JobDetails>> getJobDetails() async {
    final response = await supabase.from('jobs').select('''
          job_id,
          job_description,
          status,
          start_time,
          end_time,
          created_at,
          users:customer_id ( name, phone_number ),
          vehicles:vehicle_id ( vehicle_name, plate_number ),
          job_tasks ( 
            task_id,
            service_id,
            status,
            duration,
            start_time,
            end_time,
            session_start_time,
            services:service_id ( service_name )
      ),
          job_parts ( parts:part_id ( part_name ) ),
          remarks ( text, created_at )
        ''');

    final List<JobDetails> jobDetailsList = [];
    for (final job in response) {
      jobDetailsList.add(
        JobDetails(
          id: job['job_id'].toString(),
          customerName: job['users']['name'],
          customerPhone: job['users']['phone_number'],
          vehicle: job['vehicles']['vehicle_name'],
          plateNumber: job['vehicles']['plate_number'],
          jobDescription: job['job_description'],
          requestedServices: (job['job_tasks'] as List? ?? []).map((jt) {
            final service = jt['services'];
            return ServiceTask(
              taskId: jt['task_id'] ?? 0,
              serviceName: service?['service_name'] ?? 'Unknown',
              status: jt['status'] ?? 'Not Started',
              duration: _parseDurationFromInterval(jt['duration']) ?? 0,
              startTime: jt['start_time'] != null
                  ? DateTime.parse(jt['start_time'])
                  : null,
              endTime: jt['end_time'] != null
                  ? DateTime.parse(jt['end_time'])
                  : null,
              sessionStartTime: jt['session_start_time'] != null
                  ? DateTime.parse(jt['session_start_time'])
                  : null,
            );
          }).toList(),
          assignedParts:
              (job['job_parts'] as List?)
                  ?.map((jp) => jp['parts']['part_name'] as String)
                  .toList() ??
              [],
          remarks:
              (job['remarks'] as List?)
                  ?.map((r) => r['text'] as String)
                  .toList() ??
              [],
          status: job['status'],
          timeElapsed: JobDetails.calculateTimeElapsed(
            job['start_time'],
            job['end_time'],
          ),
          createdAt: DateTime.parse(job['created_at']),
        ),
      );
    }

    return jobDetailsList;
  }

  Future<List<JobDetails>> getCompletedJobs() async {
    final userId = 2; // Bypass auth for now
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
            job_tasks (
              task_id,
              service_id,
              status,
              duration,
              start_time,
              end_time,
              session_start_time,
              services:service_id ( service_name )
            ),
            job_parts ( parts:part_id ( part_name ) ),
            remarks ( text, created_at )
          ''')
        .eq('mechanic_id', userId)
        .eq('status', 'Completed');

    final List<JobDetails> jobDetailsList = [];
    for (final job in response) {
      jobDetailsList.add(
        JobDetails(
          id: job['job_id'].toString(),
          customerName: job['users']['name'],
          customerPhone: job['users']['phone_number'],
          vehicle: job['vehicles']['vehicle_name'],
          plateNumber: job['vehicles']['plate_number'],
          jobDescription: job['job_description'],
          requestedServices: (job['job_tasks'] as List? ?? []).map((jt) {
            final service = jt['services'];
            return ServiceTask(
              taskId: jt['task_id'] ?? 0,
              serviceName: service?['service_name'] ?? 'Unknown',
              status: jt['status'] ?? 'Not Started',
              duration: _parseDurationFromInterval(jt['duration']) ?? 0,
              startTime: jt['start_time'] != null
                  ? DateTime.parse(jt['start_time'])
                  : null,
              endTime: jt['end_time'] != null
                  ? DateTime.parse(jt['end_time'])
                  : null,
              sessionStartTime: jt['session_start_time'] != null
                  ? DateTime.parse(jt['session_start_time'])
                  : null,
            );
          }).toList(),
          assignedParts:
              (job['job_parts'] as List?)
                  ?.map((jp) => jp['parts']['part_name'] as String)
                  .toList() ??
              [],
          remarks:
              (job['remarks'] as List?)
                  ?.map((r) => r['text'] as String)
                  .toList() ??
              [],
          status: job['status'],
          timeElapsed: JobDetails.calculateTimeElapsed(
            job['start_time'],
            job['end_time'],
          ),
          createdAt: DateTime.parse(job['created_at']),
        ),
      );
    }

    return jobDetailsList;
  }

  Future<JobDetails> getSingleJobDetails(String jobId) async {
    final response = await supabase.from('jobs').select('''
          job_id,
          job_description,
          status,
          start_time,
          end_time,
          created_at,
          users:customer_id ( name, phone_number ),
          vehicles:vehicle_id ( vehicle_name, plate_number ),
          job_tasks ( 
            task_id,
            service_id,
            status,
            duration,
            start_time,
            end_time,
            session_start_time,
            services:service_id ( service_name )
      ),
          job_parts ( parts:part_id ( part_name ) ),
          remarks ( text, created_at )
        ''').eq('job_id', int.parse(jobId)).single();

    final job = response;

    return JobDetails(
      id: job['job_id'].toString(),
      customerName: job['users']['name'],
      customerPhone: job['users']['phone_number'],
      vehicle: job['vehicles']['vehicle_name'],
      plateNumber: job['vehicles']['plate_number'],
      jobDescription: job['job_description'],
      requestedServices: (job['job_tasks'] as List? ?? []).map((jt) {
        final service = jt['services'];
        return ServiceTask(
          taskId: jt['task_id'] ?? 0,
          serviceName: service?['service_name'] ?? 'Unknown',
          status: jt['status'] ?? 'Not Started',
          duration: _parseDurationFromInterval(jt['duration']) ?? 0,
          startTime: jt['start_time'] != null
              ? DateTime.parse(jt['start_time'])
              : null,
          endTime: jt['end_time'] != null
              ? DateTime.parse(jt['end_time'])
              : null,
          sessionStartTime: jt['session_start_time'] != null
              ? DateTime.parse(jt['session_start_time'])
              : null,
        );
      }).toList(),
      assignedParts:
          (job['job_parts'] as List?)
              ?.map((jp) => jp['parts']['part_name'] as String)
              .toList() ??
          [],
      remarks:
          (job['remarks'] as List?)
              ?.map((r) => r['text'] as String)
              .toList() ??
          [],
      status: job['status'],
      timeElapsed: _calculateTimeElapsed(
        job['start_time'],
        job['end_time'],
      ),
      createdAt: DateTime.parse(job['created_at']),
    );
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await supabase.from('jobs').update({'status': status}).eq('job_id', jobId);
  }

  Future<List<String>> getAllServices() async {
    final response = await supabase.from('services').select('service_name');
    return (response as List)
        .map((row) => row['service_name'] as String)
        .toList();
  }

  Future<List<String>> getAllParts() async {
    final response = await supabase.from('parts').select('part_name');
    return (response as List).map((row) => row['part_name'] as String).toList();
  }

  Future<List<ServiceHistoryItem>> getServiceHistory(String plateNumber) async {
    try {
      // 1. Find the vehicle_id for the given plate number.
      final vehicleResponse = await supabase
          .from('vehicles')
          .select('vehicle_id')
          .eq('plate_number', plateNumber)
          .maybeSingle();

      if (vehicleResponse == null) {
        return []; // No vehicle found with this plate number.
      }
      final vehicleId = vehicleResponse['vehicle_id'];

      // 2. Get all history entries for the vehicle, joining with jobs and other tables.
      final historyResponse = await supabase
          .from('vehicle_service_history')
          .select('''
            service_date,
            jobs:job_id (
              job_id,
              job_description,
              status,
              start_time,
              end_time,
              users:customer_id ( name, phone_number ),
              vehicles:vehicle_id ( vehicle_name, plate_number ),
              job_tasks ( services:service_id ( service_name ) ),
              job_parts ( parts:part_id ( part_name ) ),
              remarks ( text, created_at )
            )
          ''')
          .eq('vehicle_id', vehicleId);

      final List<ServiceHistoryItem> serviceHistoryList = [];
      for (final historyItem in historyResponse) {
        final job = historyItem['jobs'];
        if (job != null) {
          serviceHistoryList.add(
            ServiceHistoryItem(
              id: job['job_id'].toString(),
              customerName: job['users']['name'],
              customerPhone: job['users']['phone_number'],
              vehicle: job['vehicles']['vehicle_name'],
              plateNumber: job['vehicles']['plate_number'],
              jobDescription: job['job_description'],
              requestedServices:
                  (job['job_tasks'] as List?)
                      ?.map((js) => js['services']['service_name'] as String)
                      .toList() ??
                  [],
              assignedParts:
                  (job['job_parts'] as List?)
                      ?.map((jp) => jp['parts']['part_name'] as String)
                      .toList() ??
                  [],
              remarks:
                  (job['remarks'] as List?)
                      ?.map((r) => r['text'] as String)
                      .toList() ??
                  [],
              status: job['status'],
              serviceDate: DateTime.parse(historyItem['service_date']),
              serviceType:
                  (job['job_tasks'] as List?)
                      ?.map((js) => js['services']['service_name'] as String)
                      .join(', ') ??
                  '',
              timeElapsed: JobDetails.calculateTimeElapsed(
                job['start_time'],
                job['end_time'],
              ),
              photos:
                  [], // Photos are in a separate table, not directly linked here.
            ),
          );
        }
      }

      return serviceHistoryList;
    } catch (e) {
      throw Exception('Failed to load service history');
    }
  }

  //Wei Heng
  String _calculateTimeElapsed(String? startTime, String? endTime) {
    if (startTime == null) return "0m";
    try {
      final start = DateTime.parse(startTime);
      final end = (endTime != null) ? DateTime.parse(endTime) : DateTime.now();
      final diff = end.difference(start);
      return "${diff.inHours}h ${diff.inMinutes % 60}m";
    } catch (e) {
      return "0m";
    }
  }

  Future<void> updateTaskStatus(
    String taskId,
    String status, {
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    DateTime? sessionStartTime,
  }) async {
    Map<String, dynamic> updateData = {'status': status};

    if (startTime != null) {
      updateData['start_time'] = startTime.toIso8601String();
    }

    if (endTime != null) {
      updateData['end_time'] = endTime.toIso8601String();
    }

    if (duration != null) {
      // Convert Duration to PostgreSQL interval format
      final hours = duration.inHours;
      final minutes = (duration.inMinutes % 60);
      final seconds = (duration.inSeconds % 60);
      updateData['duration'] =
          '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    // Handle session_start_time
    if (sessionStartTime != null) {
      updateData['session_start_time'] = sessionStartTime.toIso8601String();
    } else if (status != "In Progress") {
      // Clear session_start_time when not in progress
      updateData['session_start_time'] = null;
    }

    await supabase
        .from('job_tasks')
        .update(updateData)
        .eq('task_id', int.parse(taskId));
  }

  // Helper method to parse PostgreSQL interval to seconds
  int _parseDurationFromInterval(dynamic durationValue) {
    if (durationValue == null) return 0;

    // If it's already an integer (seconds), return it
    if (durationValue is int) {
      return durationValue;
    }

    // If it's a string, try to parse it
    String interval = durationValue.toString();

    try {
      if (interval.contains(':')) {
        // Format: "HH:MM:SS" or "HH:MM:SS.mmm"
        final parts = interval.split(':');
        if (parts.length >= 3) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final seconds =
              int.tryParse(parts[2].split('.')[0]) ?? 0; // Remove milliseconds
          final result = hours * 3600 + minutes * 60 + seconds;
          return result;
        }
      }

      // Try parsing as direct number
      final directParse = int.tryParse(interval);
      if (directParse != null) {
        return directParse;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }
}
