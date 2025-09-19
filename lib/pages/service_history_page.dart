import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_assignment/auth/auth_service.dart';
import '../models/service_history_item.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'service_history_details_page.dart';

import 'package:mobile_assignment/models/job_details.dart';
import 'package:mobile_assignment/services/supabase_service.dart';

class ServiceHistoryPage extends StatefulWidget {
  const ServiceHistoryPage({super.key});

  @override
  State<ServiceHistoryPage> createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends State<ServiceHistoryPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'This Week', 'This Month', 'This Year'];
  final TextEditingController _searchController = TextEditingController();

  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();

  String? selectedService;
  String? selectedPart;
  List<String> allServices = [];
  List<String> allParts = [];
  List<JobDetails> _completedJobs = [];

  StreamSubscription? _jobsSubscription;
  StreamSubscription? _servicesSubscription;
  StreamSubscription? _partsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _subscribeToUpdates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _jobsSubscription?.cancel();
    _servicesSubscription?.cancel();
    _partsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      final mechanicId = await _authService.getCurrentUserId();
      if (mechanicId == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not identify the current mechanic.')),
        );
        return;
      }

      final results = await Future.wait([
        _supabaseService.getJobDetails(mechanicId: mechanicId),
        _supabaseService.getAllServices(),
        _supabaseService.getAllParts(),
      ]);
      if (mounted) {
        setState(() {
          _completedJobs = (results[0] as List<JobDetails>)
              .where((job) => job.status == 'Completed')
              .toList();
          allServices = results[1] as List<String>;
          allParts = results[2] as List<String>;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: ${e.toString()}')),
        );
      }
    }
  }

  void _subscribeToUpdates() {
    _jobsSubscription = _supabaseService.getJobsStream().listen((_) => _fetchInitialData());
    _servicesSubscription = _supabaseService.getServicesStream().listen((_) => _fetchInitialData());
    _partsSubscription = _supabaseService.getPartsStream().listen((_) => _fetchInitialData());
  }

  List<JobDetails> _filterItems(List<JobDetails> items) {
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      items = items.where((item) {
        return item.plateNumber.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            item.customerName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }).toList();
    }

    // Apply date filter
    if (selectedFilter != 'All') {
      final now = DateTime.now();
      switch (selectedFilter) {
        case 'This Week':
          items = items.where((item) {
            final difference = now.difference(item.createdAt).inDays;
            return difference <= 7;
          }).toList();
          break;
        case 'This Month':
          items = items.where((item) {
            return item.createdAt.month == now.month &&
                item.createdAt.year == now.year;
          }).toList();
          break;
        case 'This Year':
          items = items.where((item) {
            return item.createdAt.year == now.year;
          }).toList();
          break;
      }
    }

    // Apply service filter
    if (selectedService != null) {
      items = items.where((item) {
        // Check if any task in the list has a matching service name
        return item.requestedServices.any((task) => task.serviceName == selectedService);
      }).toList();
    }

    // Apply part filter
    if (selectedPart != null) {
      items = items.where((item) {
        return item.assignedParts.contains(selectedPart);
      }).toList();
    }

    return items;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Date'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: filters.map((filter) {
                  return RadioListTile<String>(
                    title: Text(filter),
                    value: filter,
                    groupValue: selectedFilter,
                    onChanged: (String? value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showServiceFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Service'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: allServices.map((service) {
                  return RadioListTile<String>(
                    title: Text(service),
                    value: service,
                    groupValue: selectedService,
                    onChanged: (String? value) {
                      setState(() {
                        selectedService = value;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedService = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showPartFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Part'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: allParts.map((part) {
                  return RadioListTile<String>(
                    title: Text(part),
                    value: part,
                    groupValue: selectedPart,
                    onChanged: (String? value) {
                      setState(() {
                        selectedPart = value;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedPart = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filterItems(_completedJobs);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Service History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121417),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for centering
                ],
              ),
            ),

            // Search Bar
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
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF61758A),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showFilterDialog,
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFF0F2F5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Filter by Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF121417),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.filter_list,
                              size: 20,
                              color: Color(0xFF121417),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showServiceFilterDialog,
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFF0F2F5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Filter by Service',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF121417),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.filter_list,
                              size: 20,
                              color: Color(0xFF121417),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showPartFilterDialog,
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFF0F2F5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Filter by Part',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF121417),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.filter_list,
                              size: 20,
                              color: Color(0xFF121417),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Service History List
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'No service history found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF61758A),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final job = items[index];
                        final item = ServiceHistoryItem(
                          id: job.id,
                          plateNumber: job.plateNumber,
                          customerName: job.customerName,
                          customerPhone: job.customerPhone,
                          vehicle: job.vehicle,
                          serviceDate: job.createdAt,
                          serviceType: job.requestedServices.map((task) => task.serviceName).join(', '),
                          status: job.status,
                          timeElapsed: job.timeElapsed,
                          jobDescription: job.jobDescription,
                          requestedServices: job.requestedServices.map((task) => task.serviceName).toList(),
                          assignedParts: job.assignedParts,
                          remarks: job.remarks,
                          photos: [], // Not available in JobDetails
                        );

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceHistoryDetailsPage(
                                  serviceHistoryItem: item,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                // Service Icon
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

                                // Service Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.plateNumber,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF121417),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.customerName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF61758A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.serviceType} • ${_formatDate(item.serviceDate)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF61758A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withAlpha(26),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4CAF50),
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
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 1),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    // Create dates with the time set to midnight to compare calendar days
    final today = DateTime(now.year, now.month, now.day);
    final otherDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(otherDate).inDays;

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
}