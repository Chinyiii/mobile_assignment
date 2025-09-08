import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/job_details.dart';
import 'job_details_page.dart';
import 'job_management_page.dart';
import 'service_history_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Job> todayJobs = [
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
  ];

  // Sample job details data
  JobDetails getJobDetails(String jobId) {
    switch (jobId) {
      case '1':
        return JobDetails(
          id: '1',
          customerName: 'Ethan Carter',
          customerPhone: '555-123-4567',
          vehicle: 'Mercedes-Benz C-Class',
          jobDescription:
              'Customer reports engine knocking and loss of power. Investigate and repair.',
          requestedServices: ['Engine Diagnostic', 'Engine Repair'],
          assignedParts: ['Spark Plugs', 'Ignition Coils'],
          remarks: ['Engine knocking sound', 'Damaged spark plugs'],
          status: 'Assigned',
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Navigate to Job Management page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobManagementPage()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121417),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121417),
                    ),
                  ),
                ],
              ),
            ),

            // Today's Jobs
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: todayJobs.length,
                itemBuilder: (context, index) {
                  final job = todayJobs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JobDetailsPage(jobDetails: getJobDetails(job.id)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: _getStatusColor(job.status).withOpacity(0.1),
                            ),
                            child: Text(
                              job.statusText,
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
            ),

            // Bottom Navigation
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F2F5), width: 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () => _onItemTapped(0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: _selectedIndex == 0 ? const Color(0xFFF0F2F5) : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.dashboard,
                              size: 24,
                              color: _selectedIndex == 0
                                  ? const Color(0xFF121417)
                                  : const Color(0xFF61758A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _selectedIndex == 0
                                  ? const Color(0xFF121417)
                                  : const Color(0xFF61758A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onItemTapped(1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: _selectedIndex == 1 ? const Color(0xFFF0F2F5) : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.work,
                              size: 24,
                              color: _selectedIndex == 1
                                  ? const Color(0xFF121417)
                                  : const Color(0xFF61758A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage Jobs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _selectedIndex == 1
                                  ? const Color(0xFF121417)
                                  : const Color(0xFF61758A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onItemTapped(2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: _selectedIndex == 2 ? const Color(0xFFF0F2F5) : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.history,
                              size: 24,
                              color: _selectedIndex == 2
                                  ? const Color(0xFF121417)
                                  : const Color(0xFF61758A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'History',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _selectedIndex == 2
                                  ? const Color(0xFF121417)
                                  : const Color(0xFF61758A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onItemTapped(3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: _selectedIndex == 3 ? const Color(0xFFF0F2F5) : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 24,
                              color: _selectedIndex == 3
                                  ? const Color(0xFF121417)
                                  : const Color(0xFF61758A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _selectedIndex == 3
                                  ? const Color(0xFF121417)
                                  : const Color(0xFF61758A),
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
}