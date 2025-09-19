import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_assignment/models/job_details.dart';
import 'package:mobile_assignment/models/service_history_item.dart';
import 'package:mobile_assignment/pages/service_history_details_page.dart';
import 'package:mobile_assignment/pages/sign-off-page.dart';
import 'package:mobile_assignment/services/supabase_service.dart';
import '../widgets/service_task_widget.dart';
import 'package:mobile_assignment/models/service_task.dart';
import 'package:mobile_assignment/pages/remark_view_page.dart';
import 'add_remark_page.dart';
import '../models/remark.dart';

class JobDetailsPage extends StatefulWidget {
  final JobDetails jobDetails;

  const JobDetailsPage({super.key, required this.jobDetails});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late JobDetails _jobDetails;
  late Future<List<ServiceHistoryItem>> _serviceHistoryFuture;
  bool _isUpdating = false;
  bool _showSignature = false;
  StreamSubscription? _jobSubscription;

  // Helper getter to check if all tasks are completed
  bool get _areAllTasksCompleted =>
      _jobDetails.requestedServices.every((task) => task.status == 'Completed');

  @override
  void initState() {
    super.initState();
    _jobDetails = widget.jobDetails;
    _serviceHistoryFuture = SupabaseService().getServiceHistory(
      _jobDetails.plateNumber,
    );
    _subscribeToJobUpdates();
  }

  @override
  void dispose() {
    _jobSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToJobUpdates() {
    _jobSubscription = SupabaseService()
        .getJobStream(_jobDetails.id)
        .listen(
          (data) {
            if (mounted) {
              print('Real-time update received for job ${_jobDetails.id}');
              _refreshJobDetails();
            }
          },
          onError: (e) {
            print('Error in real-time subscription: $e');
            _showErrorSnackBar('Connection to real-time updates failed.');
          },
        );
  }

  // --- Task Action Handlers ---

  Future<void> _startTask(ServiceTask task) async {
    setState(() => _isUpdating = true);
    try {
      final now = DateTime.now();
      DateTime? startTime =
          task.startTime; // Keep original start time if it exists
      startTime ??= now;

      await SupabaseService().updateTaskStatus(
        task.taskId,
        'In Progress',
        startTime: startTime,
        sessionStartTime: now, // Always set session start time on play
      );
      await _refreshJobDetails();
    } catch (e) {
      _showErrorSnackBar('Failed to start task: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _pauseTask(ServiceTask task) async {
    setState(() => _isUpdating = true);
    try {
      // Calculate the elapsed time for this session
      final sessionDuration = task.sessionStartTime != null
          ? DateTime.now().difference(task.sessionStartTime!)
          : Duration.zero;
      final newTotalDuration =
          Duration(seconds: task.duration) + sessionDuration;

      await SupabaseService().updateTaskStatus(
        task.taskId,
        'Paused',
        duration: newTotalDuration,
        sessionStartTime: null, // Clear session start time on pause
      );
      await _refreshJobDetails();
    } catch (e) {
      _showErrorSnackBar('Failed to pause task: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _completeTask(ServiceTask task) async {
    setState(() => _isUpdating = true);
    try {
      Duration finalDuration = Duration(seconds: task.duration);
      if (task.status == 'In Progress' && task.sessionStartTime != null) {
        final sessionDuration = DateTime.now().difference(
          task.sessionStartTime!,
        );
        finalDuration += sessionDuration;
      }

      await SupabaseService().updateTaskStatus(
        task.taskId,
        'Completed',
        endTime: DateTime.now(),
        duration: finalDuration,
        sessionStartTime: null,
      );
      await _refreshJobDetails();
    } catch (e) {
      _showErrorSnackBar('Failed to complete task: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // --- General UI and Status Logic ---

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _refreshJobDetails() async {
    try {
      print('Refreshing job details for job ID: ${_jobDetails.id}');
      final freshJobDetails = await SupabaseService().getSingleJobDetails(
        _jobDetails.id,
      );

      print('Fresh job details received:');
      print('- Status: ${freshJobDetails.status}');
      print('- Signature URL: ${freshJobDetails.signatureUrl}');

      if (mounted) {
        setState(() {
          print('Updating _jobDetails state...');
          final oldSignatureUrl = _jobDetails.signatureUrl;
          _jobDetails = freshJobDetails;
          print(
            'State updated. Old signature: $oldSignatureUrl, New signature: ${_jobDetails.signatureUrl}',
          );
        });
      } else {
        print('Widget not mounted, skipping state update');
      }
    } catch (e) {
      print('Error in _refreshJobDetails: $e');
      _showErrorSnackBar('Failed to refresh job details.');
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Job'),
          content: const Text('Are you sure you want to cancel this job?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes, Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                _updateStatus('Cancelled');
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangeStatusDialog() {
    const Map<String, List<String>> statusTransitions = {
      'Pending': ['In Progress', 'Cancelled'],
      'In Progress': ['On Hold', 'Completed', 'Cancelled'],
      'On Hold': ['In Progress', 'Cancelled'],
    };

    final currentStatus = _jobDetails.status;
    var availableTransitions = statusTransitions[currentStatus] ?? [];

    if (_areAllTasksCompleted) {
      availableTransitions = availableTransitions
          .where((s) => s != 'On Hold')
          .toList();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Status To'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableTransitions.isEmpty
                ? [const Text('No further actions available.')]
                : availableTransitions.map((nextStatus) {
                    bool isEnabled = true;
                    String title = nextStatus;

                    if (nextStatus == 'Completed' && !_areAllTasksCompleted) {
                      isEnabled = false;
                      title = 'Completed (Finish all tasks first)';
                    }

                    return ListTile(
                      title: Text(
                        title,
                        style: TextStyle(
                          color: isEnabled ? Colors.black : Colors.grey,
                        ),
                      ),
                      onTap: isEnabled
                          ? () {
                              Navigator.of(context).pop();
                              if (nextStatus == 'Cancelled') {
                                _showCancelConfirmationDialog();
                              } else {
                                _updateStatus(nextStatus);
                              }
                            }
                          : null,
                    );
                  }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      if (newStatus == 'On Hold') {
        final tasksToPause = _jobDetails.requestedServices.where(
          (task) => task.status == 'In Progress',
        );
        for (final task in tasksToPause) {
          await _pauseTask(task); // Use the new handler
        }
      }

      await SupabaseService().updateJobStatus(_jobDetails.id, newStatus);
      await _refreshJobDetails();
      _showSuccessSnackBar('Status updated to $newStatus');
    } catch (e) {
      _showErrorSnackBar('Error updating status: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildJobDetailsHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomerSection(),
                        _buildVehicleSection(),
                        _buildJobStatusSection(),
                        _buildJobDescriptionSection(),
                        _buildRequestedServicesSection(),
                        _buildAssignedPartsSection(),
                        _buildRemarksSection(),
                        _buildVehicleServiceHistorySection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
          if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildJobDetailsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFF2F2F5),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF121417),
                size: 24,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Job Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121417),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Customer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: const Color(0xFFF2F2F5),
                ),
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: Color(0xFF6B7582),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _jobDetails.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF121417),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _jobDetails.customerPhone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7582),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF2F2F5),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFF121417),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _jobDetails.plateNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF121417),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _jobDetails.vehicle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7582),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Job Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _jobDetails.status,
                style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Job Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            _jobDetails.jobDescription,
            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestedServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Requested Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        ..._jobDetails.requestedServices.map(
          (task) => ServiceTaskWidget(
            task: task,
            jobStatus: _jobDetails.status,
            isUpdating: _isUpdating,
            onStart: () => _startTask(task),
            onPause: () => _pauseTask(task),
            onComplete: () => _completeTask(task),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignedPartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Assigned Parts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        ..._jobDetails.assignedParts.map(
          (part) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF2F2F5),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xFF121417),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    part,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF121417),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // remarks
  void onAddRemark() {
    _navigateToAddRemarkPage();
  }

  void onDeleteRemark(int remarkId) async {
    await SupabaseService().deleteRemark(remarkId);
    setState(() {
      _jobDetails.remarks.removeWhere((r) => r.id == remarkId);
    });
  }

  void _showDeleteConfirmationDialog(int remarkId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Remark'),
          content: const Text('Are you sure you want to delete this remark?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                onDeleteRemark(remarkId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToAddRemarkPage() async {
    final newRemark = await Navigator.push<Remark>(
      context,
      MaterialPageRoute(
        builder: (context) => RemarkFormPage(jobId: _jobDetails.id, userId: 2),
      ),
    );

    if (newRemark != null) {
      setState(() {
        final updatedRemarks = List<Remark>.from(_jobDetails.remarks)
          ..add(newRemark);

        _jobDetails = JobDetails(
          id: _jobDetails.id,
          customerName: _jobDetails.customerName,
          customerPhone: _jobDetails.customerPhone,
          vehicle: _jobDetails.vehicle,
          plateNumber: _jobDetails.plateNumber,
          jobDescription: _jobDetails.jobDescription,
          requestedServices: _jobDetails.requestedServices,
          assignedParts: _jobDetails.assignedParts,
          remarks: updatedRemarks,
          status: _jobDetails.status,
          timeElapsed: _jobDetails.timeElapsed,
          createdAt: _jobDetails.createdAt,
        );
      });
    }
  }

  Widget _buildRemarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Remarks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        if (_jobDetails.remarks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No remarks yet.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7582)),
            ),
          )
        else
          ..._jobDetails.remarks.map(
            (remark) => GestureDetector(
            onTap: () {
              // 👇 Navigate to read-only view page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RemarkViewPage(remark: remark),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF2F2F5),
                    ),
                    child: const Icon(
                      Icons.note,
                      color: Color(0xFF121417),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Remark text + images
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (remark.text.trim().isNotEmpty)
                          Text(
                            remark.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis, // preview only
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7582),
                            ),
                          ),
                        const SizedBox(height: 6),
                        if (remark.imageUrls.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: remark.imageUrls
                                .where((url) => url.isNotEmpty)
                                .take(2) // 👈 preview up to 2 images
                                .map((url) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      url,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 20,
                                                ),
                                              ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                      ],
                    ),
                  ),

                  // Edit + Delete buttons (unchanged)
                  if (_jobDetails.status != 'Completed' && _jobDetails.status != 'Cancelled')
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () async {
                            final updatedRemark = await Navigator.push<Remark>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RemarkFormPage(
                                  jobId: _jobDetails.id,
                                  userId: 2,
                                  remark: remark,
                                ),
                              ),
                            );

                            if (updatedRemark != null) {
                              final idx = _jobDetails.remarks.indexWhere(
                                (r) => r.id == updatedRemark.id,
                              );
                              if (idx != -1) {
                                _jobDetails.remarks[idx] = updatedRemark;
                                (context as Element).markNeedsBuild();
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),
                          onPressed: () => _showDeleteConfirmationDialog(remark.id),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleServiceHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Vehicle Service History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        FutureBuilder<List<ServiceHistoryItem>>(
          future: _serviceHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading service history'));
            }
            final serviceHistory = snapshot.data;
            if (serviceHistory == null || serviceHistory.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'No service history for this vehicle.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7582)),
                ),
              );
            }
            return Column(
              children: serviceHistory.map((item) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ServiceHistoryDetailsPage(serviceHistoryItem: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF2F2F5),
                          ),
                          child: const Icon(
                            Icons.build,
                            color: Color(0xFF121417),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.serviceType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(item.serviceDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7582),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    // If job is Cancelled, hide everything
    if (_jobDetails.status == 'Cancelled') {
      return const SizedBox.shrink();
    }

    // ✅ If job is Completed
    if (_jobDetails.status == 'Completed') {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_jobDetails.signatureUrl == null ||
                _jobDetails.signatureUrl!.isEmpty)
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DigitalSignOffPage(jobId: _jobDetails.id),
                    ),
                  );

                  if (result == true) {
                    print(
                      'Signature page returned success, refreshing job details...',
                    );

                    // Since the signature page only returns true when signature is confirmed saved,
                    // we can do a simple refresh with shorter delay
                    await Future.delayed(const Duration(milliseconds: 500));

                    try {
                      final freshJobDetails = await SupabaseService()
                          .getSingleJobDetails(_jobDetails.id);
                      print('Fresh job details loaded');
                      print(
                        'New signature URL: ${freshJobDetails.signatureUrl}',
                      );

                      if (mounted) {
                        setState(() {
                          _jobDetails = freshJobDetails;
                        });

                        // Show success message to user
                        _showSuccessSnackBar('Signature saved successfully!');
                      }
                    } catch (e) {
                      print('Error refreshing job details: $e');
                      _showErrorSnackBar(
                        'Signature saved but failed to refresh display.',
                      );
                    }
                  }
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFDEE8F2),
                  ),
                  child: const Center(
                    child: Text(
                      'Customer Sign-Off',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121417),
                      ),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  const Text(
                    "Customer Sign-Off",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF121417),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 👇 Updated toggle button with matching design
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSignature = !_showSignature;
                      });
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFDEE8F2),
                      ),
                      child: Center(
                        child: Text(
                          _showSignature ? "Hide Signature" : "Show Signature",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121417),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 👇 Only build FutureBuilder if toggled ON
                  if (_showSignature)
                    FutureBuilder<String?>(
                      future: SupabaseService().getSignedUrl(
                        _jobDetails.signatureUrl!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return const Text(
                            "Failed to load signature",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7582),
                            ),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF2F2F5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              snapshot.data!,
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showChangeStatusDialog,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFDEE8F2),
                ),
                child: const Center(
                  child: Text(
                    'Change Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121417),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onAddRemark,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF2F2F5),
                ),
                child: const Center(
                  child: Text(
                    'Add Remarks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121417),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
