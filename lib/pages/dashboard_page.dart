import 'package:flutter/material.dart';
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
  late Future<List<JobDetails>> _jobDetailsFuture;

  @override
  void initState() {
    super.initState();
    _jobDetailsFuture = SupabaseService().getJobDetails();
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
              child: FutureBuilder<List<JobDetails>>(
                future: _jobDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching jobs'));
                  }
                  final jobs = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JobDetailsPage(jobDetails: job),
                            ),
                          ).then((result) {
                            if (result == true) {
                              setState(() {
                                _jobDetailsFuture = SupabaseService()
                                    .getJobDetails();
                              });
                            }
                          });
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
                                  color: _getStatusColor(
                                    job.status,
                                  ).withAlpha(26),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 0),
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
