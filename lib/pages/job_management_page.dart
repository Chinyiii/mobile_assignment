import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/job_details.dart';
import 'job_details_page.dart';
import 'dashboard_page.dart';
import 'add_job_page.dart';
import 'service_history_page.dart';
import 'profile_page.dart';

class JobManagementPage extends StatefulWidget {
  const JobManagementPage({super.key});

  @override
  State<JobManagementPage> createState() => _JobManagementPageState();
}

class _JobManagementPageState extends State<JobManagementPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'In Progress', 'Completed'];

  final List<Job> jobs = [
    Job(
      id: '1',
      title: 'Oil Change',
      vehicle: 'Mercedes-Benz C-Class',
      status: JobStatus.assigned,
      date: DateTime.now(),
    ),
    Job(
      id: '2',
      title: 'Brake Repair',
      vehicle: 'BMW 3 Series',
      status: JobStatus.inProgress,
      date: DateTime.now(),
    ),
    Job(
      id: '3',
      title: 'Tire Replacement',
      vehicle: 'Audi A4',
      status: JobStatus.completed,
      date: DateTime.now(),
    ),
    Job(
      id: '4',
      title: 'Tire Change',
      vehicle: 'Ford Focus',
      status: JobStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Sample job details data
  JobDetails getJobDetails(String jobId) {
    switch (jobId) {
      case '1':
        return JobDetails(
          id: '1',
          customerName: 'Ethan Carter',
          customerPhone: '555-123-4567',
          vehicle: '2018 Ford F-150',
          jobDescription:
              'Customer reports engine knocking and loss of power. Investigate and repair.',
          requestedServices: ['Engine Diagnostic', 'Engine Repair'],
          assignedParts: ['Spark Plugs', 'Ignition Coils'],
          remarks: ['Engine knocking sound', 'Damaged spark plugs'],
          status: 'In Progress',
          timeElapsed: '1h 15m',
        );
      case '2':
        return JobDetails(
          id: '2',
          customerName: 'Sarah Johnson',
          customerPhone: '555-987-6543',
          vehicle: 'BMW 3 Series',
          jobDescription:
              'Brake pedal feels soft and vehicle pulls to the right when braking.',
          requestedServices: ['Brake Inspection', 'Brake Repair'],
          assignedParts: ['Brake Pads', 'Brake Fluid'],
          remarks: ['Soft brake pedal', 'Right side brake wear'],
          status: 'In Progress',
          timeElapsed: '45m',
        );
      case '3':
        return JobDetails(
          id: '3',
          customerName: 'Michael Chen',
          customerPhone: '555-456-7890',
          vehicle: 'Audi A4',
          jobDescription: 'Replace all four tires due to wear and tear.',
          requestedServices: ['Tire Replacement'],
          assignedParts: ['Tires (4x)', 'Wheel Balancing'],
          remarks: ['Uneven tire wear', 'Tire pressure check completed'],
          status: 'Completed',
          timeElapsed: '2h 30m',
        );
      case '4':
        return JobDetails(
          id: '4',
          customerName: 'Lisa Rodriguez',
          customerPhone: '555-321-0987',
          vehicle: 'Ford Focus',
          jobDescription: 'Replace front tires and perform alignment.',
          requestedServices: ['Tire Change', 'Wheel Alignment'],
          assignedParts: ['Front Tires (2x)', 'Alignment Service'],
          remarks: ['Front tire wear', 'Alignment completed'],
          status: 'Completed',
          timeElapsed: '1h 45m',
        );
      default:
        return JobDetails(
          id: jobId,
          customerName: 'Unknown Customer',
          customerPhone: 'N/A',
          vehicle: 'Unknown Vehicle',
          jobDescription: 'No description available.',
          requestedServices: [],
          assignedParts: [],
          remarks: [],
          status: 'Unknown',
          timeElapsed: 'N/A',
        );
    }
  }

  List<Job> get filteredJobs {
    if (selectedFilter == 'All') {
      return jobs;
    }
    return jobs.where((job) => job.statusText == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (inlined)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jobs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121417),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddJobPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFFF0F2F5),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF121417),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (inlined)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF0F2F5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        color: Color(0xFFF0F2F5),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Color(0xFF61758A),
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Search jobs',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF61758A).withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Tabs (inlined)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: filters.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isSelected
                              ? const Color(0xFFF0F2F5)
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filter,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF121417)
                                    : const Color(0xFF61758A),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFF121417),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Job List
            Expanded(
              child: Builder(
                builder: (context) {
                  final groupedJobs = <String, List<Job>>{};
                  for (final job in filteredJobs) {
                    final dateKey = job.dateText;
                    groupedJobs.putIfAbsent(dateKey, () => []);
                    groupedJobs[dateKey]!.add(job);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupedJobs.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedJobs.keys.elementAt(index);
                      final jobsForDate = groupedJobs[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                            child: Text(
                              dateKey,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF121417),
                              ),
                            ),
                          ),
                          // Jobs for this date
                          ...jobsForDate.map(
                            (job) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobDetailsPage(
                                      jobDetails: getJobDetails(job.id),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job.title,
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
                                        color: _getStatusColor(
                                          job.status,
                                        ).withOpacity(0.1),
                                      ),
                                      child: Text(
                                        job.statusText,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _getStatusColor(job.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Navigation (inlined)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF0F2F5), width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.dashboard, 'Dashboard', false),
                    _buildNavItem(1, Icons.work, 'Manage Jobs', true),
                    _buildNavItem(2, Icons.history, 'History', false),
                    _buildNavItem(3, Icons.person, 'Profile', false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.assigned:
        return const Color(0xFF2196F3);
      case JobStatus.inProgress:
        return const Color(0xFFFF9800);
      case JobStatus.completed:
        return const Color(0xFF4CAF50);
    }
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? const Color(0xFFF0F2F5) : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF121417)
                  : const Color(0xFF61758A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF121417)
                  : const Color(0xFF61758A),
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to Dashboard page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (index == 2) {
      // Navigate to Service History page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ServiceHistoryPage()),
      );
    } else if (index == 3) {
      // Navigate to Profile page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }
}
