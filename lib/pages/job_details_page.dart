import 'package:flutter/material.dart';
import 'package:mobile_assignment/models/job_details.dart';
import 'package:mobile_assignment/models/service_history_item.dart';
import 'package:mobile_assignment/pages/service_history_details_page.dart';
import 'package:mobile_assignment/services/supabase_service.dart';
import '../widgets/service_task_widget.dart';
import 'package:mobile_assignment/models/service_task.dart';

// Displays the details of a specific job.
class JobDetailsPage extends StatefulWidget {
  // The job details to be displayed.
  final JobDetails jobDetails;

  const JobDetailsPage({super.key, required this.jobDetails});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  // The current job details.
  late JobDetails _jobDetails;

  // A future that resolves to a list of service history items for the vehicle.
  late Future<List<ServiceHistoryItem>> _serviceHistoryFuture;

  // Whether the page is currently updating.
  bool _isUpdating = false;

  // Helper getter to check if all tasks are completed.
  bool get _areAllTasksCompleted =>
      _jobDetails.requestedServices.every((task) => task.status == 'Completed');

  @override
  void initState() {
    super.initState();
    _jobDetails = widget.jobDetails;
    _serviceHistoryFuture = SupabaseService().getServiceHistory(
      _jobDetails.plateNumber,
    );
  }

  // --- Task Action Handlers ---

  // Starts a service task.
  Future<void> _startTask(ServiceTask task) async {
    setState(() => _isUpdating = true);
    try {
      final now = DateTime.now();
      DateTime? startTime =
          task.startTime; // Keep original start time if it exists
      if (startTime == null) {
        startTime = now; // Set start time if it's the first time
      }

      await SupabaseService().updateTaskStatus(
        task.taskId.toString(),
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

  // Pauses a service task.
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
        task.taskId.toString(),
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

  // Completes a service task.
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
        task.taskId.toString(),
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

  // Shows a success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Shows an error snackbar.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Refreshes the job details.
  Future<void> _refreshJobDetails() async {
    try {
      final freshJobDetails = await SupabaseService().getSingleJobDetails(
        _jobDetails.id,
      );
      if (mounted) {
        setState(() {
          _jobDetails = freshJobDetails;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to refresh job details.');
    }
  }

  // Shows a confirmation dialog before cancelling a job.
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

  // Shows a dialog to change the job status.
  void _showChangeStatusDialog() {
    const Map<String, List<String>> statusTransitions = {
      //Maps each status to the statuses it can move to
      'Pending': ['In Progress', 'Cancelled'],
      'In Progress': ['On Hold', 'Completed', 'Cancelled'],
      'On Hold': ['In Progress', 'Cancelled'],
    };

    final currentStatus = _jobDetails.status;
    //If there is non valid next statuses then it will defaults to empty list
    final availableTransitions = statusTransitions[currentStatus] ?? [];

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

  // Updates the job status.
  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      if (newStatus == 'On Hold') {
        final tasksToPause = _jobDetails.requestedServices.where(
          //To find which task status is 'In Progress'
          (task) => task.status == 'In Progress',
        );
        for (final task in tasksToPause) {
          await _pauseTask(task); // Use the new handler
        }
      }

      await SupabaseService().updateJobStatus(_jobDetails.id, newStatus);
      await _refreshJobDetails(); //To reload the job details from the backend
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

  // Formats a date for the Vehicle Service History
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

  //Main build
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
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Header widgets
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

  // Customer section of the job details page
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

  //Vehicle section of the job details page
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

  //Job status section of the job details page
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
              Text(
                _jobDetails.timeElapsed,
                style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //Job description section of the job details page
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

  //Requested services section of the job details page
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
            isUpdating: _isUpdating,
            onStart: () => _startTask(task),
            onPause: () => _pauseTask(task),
            onComplete: () => _completeTask(task),
          ),
        ),
      ],
    );
  }

  //Assigned parts section of the job details page
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

  //Remarks section of the job details page
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
        ..._jobDetails.remarks.asMap().entries.map(
          (entry) => Padding(
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
                    Icons.note,
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
                        'Note ${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF121417),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
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
        ),
      ],
    );
  }

  //Vehicle service history section of the job details page
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

  //Action buttons at the bottom of the job details page
  Widget _buildActionButtons() {
    // Hide button if job is completed or cancelled
    if (_jobDetails.status == 'Completed' ||
        _jobDetails.status == 'Cancelled') {
      return const SizedBox.shrink(); // Return an empty widget
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
        ],
      ),
    );
  }
}
