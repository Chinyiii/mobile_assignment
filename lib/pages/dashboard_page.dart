import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_assignment/auth/auth_service.dart';
import 'package:mobile_assignment/models/job_details.dart';
import 'package:mobile_assignment/services/supabase_service.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'job_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<JobDetails> _allJobs = [];
  List<JobDetails> _pendingJobs = [];
  List<JobDetails> _inProgressJobs = [];
  List<JobDetails> _onHoldJobs = [];
  List<JobDetails> _completedJobs = [];
  List<JobDetails> _cancelledJobs = [];

  bool _isLoading = true;
  StreamSubscription? _jobsSubscription;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchInitialJobs();
    _subscribeToJobsUpdates();
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitialJobs() async {
    try {
      final mechanicId = await _authService.getCurrentUserId();
      if (mechanicId == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not identify the current mechanic.'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final jobs = await SupabaseService().getJobDetails(
        mechanicId: mechanicId,
      );
      if (mounted) {
        setState(() {
          _allJobs = jobs;
          _pendingJobs = _allJobs
              .where((job) => job.status == 'Pending')
              .toList();
          _inProgressJobs = _allJobs
              .where((job) => job.status == 'In Progress')
              .toList();
          _onHoldJobs = _allJobs
              .where((job) => job.status == 'On Hold')
              .toList();
          _completedJobs = _allJobs
              .where((job) => job.status == 'Completed')
              .toList();
          _cancelledJobs = _allJobs
              .where((job) => job.status == 'Cancelled')
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching jobs: ${e.toString()}')),
        );
      }
    }
  }

  void _subscribeToJobsUpdates() {
    _jobsSubscription = SupabaseService().getJobsStream().listen(
      (data) {
        if (mounted) {
          print('Real-time update received for jobs list');
          _fetchInitialJobs();
        }
      },
      onError: (e) {
        print('Error in real-time subscription: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  const Expanded(
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121417),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Today's Jobs
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _allJobs.isEmpty
                  ? const Center(
                      child: Text(
                        'No jobs assigned for today.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF61758A),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJobList('In Progress', _inProgressJobs),
                          _buildJobList('Pending', _pendingJobs),
                          _buildJobList('On Hold', _onHoldJobs),
                          _buildJobList('Completed', _completedJobs),
                          _buildJobList('Cancelled', _cancelledJobs),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 0),
    );
  }

  Widget _buildJobList(String title, List<JobDetails> jobs) {
    if (jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF121417),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsPage(jobDetails: job),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Job Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF0F2F5),
                      ),
                      child: const Icon(
                        Icons.build,
                        color: Color(0xFF121417),
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Job Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.jobDescription,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF121417),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.vehicle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF61758A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _getStatusColor(job.status).withAlpha(26),
                      ),
                      child: Text(
                        job.status,
                        style: TextStyle(
                          fontSize: 16,
                          color: _getStatusColor(job.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.grey; // Not started
      case 'Assigned':
        return const Color(0xFF2196F3); // Blue
      case 'In Progress':
        return const Color(0xFFFF9800); // Orange
      case 'On Hold':
        return const Color(0xFF9C27B0); // Purple
      case 'Completed':
        return const Color(0xFF4CAF50); // Green
      case 'Cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.black54; // Fallback
    }
  }
}
