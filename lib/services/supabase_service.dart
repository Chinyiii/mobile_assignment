import 'dart:io';
import 'package:mobile_assignment/models/service_history_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_assignment/models/job_details.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../models/remark.dart';
import '../models/service_task.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  // ===================== JOBS =====================
  ///Fetch all job details for like dashboard, service history
  Future<List<JobDetails>> getJobDetails({int? mechanicId}) async {
    var query = supabase.from('jobs').select('''
      job_id,
      job_description,
      status,
      start_time,
      end_time,
      created_at,
      sign_off_url,
      users:customer_id ( name, phone_number ),
      vehicles:vehicle_id ( vehicle_name, plate_number ),
      job_tasks ( task_id, service_id, status, duration, start_time, end_time, session_start_time, services:service_id ( service_name ) ),
      job_parts ( parts:part_id ( part_name ) ),
      remarks (
        remark_id,
        text,
        remark_photos ( photo_url )
      )
    ''');

    /// To show the jobs or history about that mechanic
    if (mechanicId != null) {
      query = query.eq('mechanic_id', mechanicId);
    }

    final response = await query;

    /// Convert each job row into a JobDetails model
    final List<JobDetails> jobDetailsList = [];
    for (final job in response) {
      jobDetailsList.add(
        JobDetails(
          id: job['job_id'],
          customerName: job['users']['name'],
          customerPhone: job['users']['phone_number'],
          vehicle: job['vehicles']['vehicle_name'],
          plateNumber: job['vehicles']['plate_number'],
          jobDescription: job['job_description'],
          // Parse job tasks into ServiceTask models
          requestedServices: (job['job_tasks'] as List? ?? []).map((jt) {
            final service = jt['services'];
            return ServiceTask(
              taskId: jt['task_id'] ?? 0,
              serviceName: service?['service_name'] ?? 'Unknown',
              status: jt['status'] ?? 'Not Started',
              duration: _parseDurationFromInterval(jt['duration']),
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
          // Extract assigned parts
          assignedParts:
              (job['job_parts'] as List?)
                  ?.map((jp) => jp['parts']['part_name'] as String)
                  .toList() ??
              [],
          // Convert remarks into Remark models
          remarks: (job['remarks'] is List)
              ? (job['remarks'] as List)
                    .whereType<Map<String, dynamic>>() // only maps
                    .map((r) => Remark.fromJson(r))
                    .toList()
              : [],
          status: job['status'],
          timeElapsed: JobDetails.calculateTimeElapsed(
            job['start_time'],
            job['end_time'],
          ),
          createdAt: DateTime.parse(job['created_at']),
          signatureUrl: job['sign_off_url'],
        ),
      );
    }

    return jobDetailsList;
  }

  /// Fetch details for a single job by its [jobId]
  Future<JobDetails> getSingleJobDetails(int jobId) async {
    final response = await supabase
        .from('jobs')
        .select('''
        job_id,
        job_description,
        status,
        start_time,
        end_time,
        created_at,
        sign_off_url,
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
        remarks (
            remark_id,
            text,
            remark_photos ( photo_url )
          )
      ''')
        .eq('job_id', jobId)
        .single();

    final job = response;

    /// Debugging print statements
    print('Raw job data: $job');
    print('sign_off_url from database: ${job['sign_off_url']}');

    return JobDetails(
      id: job['job_id'],
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
          duration: _parseDurationFromInterval(jt['duration']),
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
      remarks: (job['remarks'] is List)
          ? (job['remarks'] as List)
                .whereType<Map<String, dynamic>>() // only maps
                .map((r) => Remark.fromJson(r))
                .toList()
          : [],
      status: job['status'],
      timeElapsed: _calculateTimeElapsed(job['start_time'], job['end_time']),
      createdAt: DateTime.parse(job['created_at']),
      signatureUrl: job['sign_off_url'],
    );
  }

  /// Update a job's status.
  Future<void> updateJobStatus(int jobId, String status) async {
    await supabase.from('jobs').update({'status': status}).eq('job_id', jobId);
  }

  // ===================== MASTER DATA =====================
  /// Fetch all service names
  Future<List<String>> getAllServices() async {
    final response = await supabase.from('services').select('service_name');
    return (response as List)
        .map((row) => row['service_name'] as String)
        .toList();
  }

  /// Fetch all part names
  Future<List<String>> getAllParts() async {
    final response = await supabase.from('parts').select('part_name');
    return (response as List).map((row) => row['part_name'] as String).toList();
  }

  // ===================== SERVICE HISTORY =====================
  /// Fetch service history for a vehicle by plateNumber
  Future<List<ServiceHistoryItem>> getServiceHistory(String plateNumber) async {
    try {
      // Find the vehicle_id for the given plate number.
      final vehicleResponse = await supabase
          .from('vehicles')
          .select('vehicle_id')
          .eq('plate_number', plateNumber)
          .maybeSingle();

      if (vehicleResponse == null) {
        return []; // No vehicle found with this plate number.
      }
      final vehicleId = vehicleResponse['vehicle_id'];

      //Get all history entries for the vehicle, joining with jobs and other tables.
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
              remarks (
                remark_id,
                text,
                remark_photos ( photo_url )
              )
            )
          ''')
          .eq('vehicle_id', vehicleId);

      final List<ServiceHistoryItem> serviceHistoryList = [];
      for (final historyItem in historyResponse) {
        final job = historyItem['jobs'];
        if (job != null) {
          serviceHistoryList.add(
            ServiceHistoryItem(
              id: job['job_id'],
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
              remarks: (job['remarks'] is List)
                  ? (job['remarks'] as List)
                        .whereType<Map<String, dynamic>>() // only maps
                        .map((r) => Remark.fromJson(r))
                        .toList()
                  : [],
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
                  [], // Photos are in a separate table, not directly linked here
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
    int taskId,
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
          '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    // Handle session_start_time
    if (sessionStartTime != null) {
      updateData['session_start_time'] = sessionStartTime.toIso8601String();
    } else if (status != "In Progress") {
      // Clear session_start_time when not in progress
      updateData['session_start_time'] = null;
    }

    await supabase.from('job_tasks').update(updateData).eq('task_id', taskId);
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

  // ===================== SIGN-OFF =====================
  Future<void> saveJobSignOff(int jobId, Uint8List signatureBytes) async {
    final String date = DateTime.now().toIso8601String().split('T').first;
    final String uniqueId = const Uuid().v4();
    final String filePath = 'signatures/job_${jobId}_${date}_$uniqueId.png';

    // Upload into private bucket
    await supabase.storage
        .from('job_asset_storage')
        .uploadBinary(
          filePath,
          signatureBytes,
          fileOptions: const FileOptions(contentType: 'image/png'),
        );

    // Save only the file path in DB
    await supabase
        .from('jobs')
        .update({'sign_off_url': filePath})
        .eq('job_id', jobId);
  }

  Future<String?> getSignedUrl(String filePath) async {
    final response = await supabase.storage
        .from('job_asset_storage')
        .createSignedUrl(filePath, 60 * 60); // valid for 1 hour
    return response;
  }

  // ===================== REAL-TIME STREAMS =====================
  Stream<List<Map<String, dynamic>>> getJobStream(int jobId) {
    return supabase
        .from('jobs')
        .stream(primaryKey: ['job_id'])
        .eq('job_id', jobId)
        .limit(1);
  }

  Stream<List<Map<String, dynamic>>> getJobsStream() {
    return supabase.from('jobs').stream(primaryKey: ['job_id']);
  }

  Stream<List<Map<String, dynamic>>> getServicesStream() {
    return supabase.from('services').stream(primaryKey: ['service_id']);
  }

  Stream<List<Map<String, dynamic>>> getPartsStream() {
    return supabase.from('parts').stream(primaryKey: ['part_id']);
  }

  // Cia Liang
  // ===================== REMARKS =====================
  Future<Remark> addRemarkWithPhotos({
    required int jobId,
    required int userId,
    required String description,
    required List<File> imageFiles,
  }) async {
    final response = await supabase
        .from('remarks')
        .insert({
          'job_id': jobId,
          'user_id': userId,
          'text': description,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final remarkId = response['remark_id'] as int;

    final uploadedUrls = <String>[];
    for (final file in imageFiles) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      await supabase.storage.from('remark_photos').upload(fileName, file);
      final publicUrl = supabase.storage
          .from('remark_photos')
          .getPublicUrl(fileName);

      uploadedUrls.add(publicUrl);

      await supabase.from('remark_photos').insert({
        'remark_id': remarkId,
        'photo_url': publicUrl,
      });
    }

    return Remark(id: remarkId, text: description, imageUrls: uploadedUrls);
  }

  Future<void> updateRemark({
    required int remarkId,
    required String newText,
    List<File>? newFiles,
  }) async {
    // Update text
    await supabase
        .from('remarks')
        .update({'text': newText})
        .eq('remark_id', remarkId);

    // Upload new images if any
    if (newFiles != null && newFiles.isNotEmpty) {
      for (var file in newFiles) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final storageResponse = await supabase.storage
            .from('remark_photos')
            .upload(fileName, file);

        final publicUrl = supabase.storage
            .from('remark_photos')
            .getPublicUrl(fileName);

        await supabase.from('remark_photos').insert({
          'remark_id': remarkId,
          'photo_url': publicUrl,
        });
      }
    }
  }

  Future<void> deleteRemark(int remarkId) async {
    try {
      //Get all photo URLs for this remark
      final photos = await supabase
          .from('remark_photos')
          .select('photo_url')
          .eq('remark_id', remarkId);

      //Delete each file from storage bucket
      for (final photo in photos) {
        final photoUrl = photo['photo_url'] as String;
        final fileName = photoUrl.split('/').last;

        final storageResp = await supabase.storage.from('remark_photos').remove(
          [fileName],
        );
        print('Deleted from bucket: $storageResp');
      }

      //Delete photo records from DB
      await supabase.from('remark_photos').delete().eq('remark_id', remarkId);
      print('Deleted photo records from DB');

      //Delete the remark itself
      await supabase.from('remarks').delete().eq('remark_id', remarkId);
      print('Deleted remark $remarkId');
    } catch (e) {
      print('Error deleting remark: $e');
    }
  }

  Future<String> uploadRemarkImage(int remarkId, File file) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

    // Upload file to storage
    await supabase.storage.from('remark_photos').upload(fileName, file);

    // Get public URL
    final publicUrl = supabase.storage
        .from('remark_photos')
        .getPublicUrl(fileName);

    // Insert record in DB
    await supabase.from('remark_photos').insert({
      'remark_id': remarkId,
      'photo_url': publicUrl,
    });

    return publicUrl;
  }

  Future<void> deleteRemarkPhoto(int remarkId, String photoUrl) async {
    try {
      // Supabase bucket stores only the filename
      final fileName = photoUrl.split('/').last;

      // Delete from storage bucket
      final storageResp = await supabase.storage.from('remark_photos').remove([
        fileName,
      ]);
      print('Deleted from bucket: $storageResp');

      // Delete record from DB
      await supabase
          .from('remark_photos')
          .delete()
          .eq('remark_id', remarkId)
          .eq('photo_url', photoUrl);

      print('Deleted from DB: $photoUrl');
    } catch (e) {
      print('Error deleting remark photo: $e');
    }
  }
}
