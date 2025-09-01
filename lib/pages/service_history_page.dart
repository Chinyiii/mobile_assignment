import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/job_details.dart';
import 'job_details_page.dart';
import 'dashboard_page.dart';
import 'job_management_page.dart';
import 'service_history_details_page.dart';
import 'profile_page.dart';

class ServiceHistoryPage extends StatefulWidget {
  const ServiceHistoryPage({super.key});

  @override
  State<ServiceHistoryPage> createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends State<ServiceHistoryPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'This Week', 'This Month', 'This Year'];
  final TextEditingController _searchController = TextEditingController();

  final List<ServiceHistoryItem> serviceHistoryItems = [
    ServiceHistoryItem(
      id: '1',
      plateNumber: 'XYZ 123',
      customerName: 'Ethan Carter',
      customerPhone: '555-123-4567',
      vehicle: '2018 Ford F-150',
      serviceDate: DateTime.now().subtract(const Duration(days: 2)),
      serviceType: 'Oil Change',
      status: 'Completed',
      timeElapsed: '1h 15m',
      jobDescription:
          'Customer reports engine knocking and loss of power. Investigate and repair.',
      requestedServices: ['Engine Diagnostic', 'Engine Repair'],
      assignedParts: ['Spark Plugs', 'Ignition Coils'],
      remarks: ['Engine knocking sound'],
      photos: ['Damaged spark plugs'],
    ),
    ServiceHistoryItem(
      id: '2',
      plateNumber: 'ABC 456',
      customerName: 'Olivia Bennett',
      customerPhone: '555-987-6543',
      vehicle: '2020 Toyota Camry',
      serviceDate: DateTime.now().subtract(const Duration(days: 5)),
      serviceType: 'Brake Repair',
      status: 'Completed',
      timeElapsed: '2h 30m',
      jobDescription:
          'Brake pedal feels soft and vehicle pulls to the right when braking.',
      requestedServices: ['Brake Inspection', 'Brake Repair'],
      assignedParts: ['Brake Pads', 'Brake Fluid'],
      remarks: ['Soft brake pedal', 'Right side brake wear'],
      photos: ['Worn brake pads'],
    ),
    ServiceHistoryItem(
      id: '3',
      plateNumber: 'DEF 789',
      customerName: 'Noah Thompson',
      customerPhone: '555-456-7890',
      vehicle: '2019 Honda Civic',
      serviceDate: DateTime.now().subtract(const Duration(days: 8)),
      serviceType: 'Tire Replacement',
      status: 'Completed',
      timeElapsed: '1h 45m',
      jobDescription: 'Replace all four tires due to wear and tear.',
      requestedServices: ['Tire Replacement'],
      assignedParts: ['Tires (4x)', 'Wheel Balancing'],
      remarks: ['Uneven tire wear', 'Tire pressure check completed'],
      photos: ['Worn tires'],
    ),
    ServiceHistoryItem(
      id: '4',
      plateNumber: 'GHI 012',
      customerName: 'Ava Harper',
      customerPhone: '555-321-6540',
      vehicle: '2021 BMW 3 Series',
      serviceDate: DateTime.now().subtract(const Duration(days: 12)),
      serviceType: 'Engine Diagnostic',
      status: 'Completed',
      timeElapsed: '45m',
      jobDescription: 'Check engine light is on, perform diagnostic scan.',
      requestedServices: ['Engine Diagnostic'],
      assignedParts: ['OBD Scanner'],
      remarks: ['Engine light on', 'Diagnostic completed'],
      photos: ['Engine compartment'],
    ),
    ServiceHistoryItem(
      id: '5',
      plateNumber: 'JKL 345',
      customerName: 'Liam Foster',
      customerPhone: '555-789-0123',
      vehicle: '2017 Audi A4',
      serviceDate: DateTime.now().subtract(const Duration(days: 15)),
      serviceType: 'Battery Replacement',
      status: 'Completed',
      timeElapsed: '30m',
      jobDescription: 'Vehicle won\'t start, battery appears to be dead.',
      requestedServices: ['Battery Replacement'],
      assignedParts: ['Car Battery'],
      remarks: ['Dead battery', 'New battery installed'],
      photos: ['Old battery'],
    ),
    ServiceHistoryItem(
      id: '6',
      plateNumber: 'MNO 678',
      customerName: 'Emma Wilson',
      customerPhone: '555-654-3210',
      vehicle: '2022 Mercedes C-Class',
      serviceDate: DateTime.now().subtract(const Duration(days: 20)),
      serviceType: 'Wheel Alignment',
      status: 'Completed',
      timeElapsed: '1h 30m',
      jobDescription: 'Vehicle pulls to the left, needs wheel alignment.',
      requestedServices: ['Wheel Alignment'],
      assignedParts: ['Alignment Service'],
      remarks: ['Vehicle pulling left', 'Alignment corrected'],
      photos: ['Wheel alignment setup'],
    ),
  ];

  List<ServiceHistoryItem> get filteredItems {
    List<ServiceHistoryItem> items = serviceHistoryItems;

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
            final difference = now.difference(item.serviceDate).inDays;
            return difference <= 7;
          }).toList();
          break;
        case 'This Month':
          items = items.where((item) {
            return item.serviceDate.month == now.month &&
                item.serviceDate.year == now.year;
          }).toList();
          break;
        case 'This Year':
          items = items.where((item) {
            return item.serviceDate.year == now.year;
          }).toList();
          break;
      }
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
                this.setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Navigate to Dashboard page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (index == 1) {
      // Navigate to Job Management page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobManagementPage()),
      );
    } else if (index == 3) {
      // Navigate to Profile page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  int _selectedIndex = 2; // History tab is selected

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            // Filter Button
            _buildFilterButton(),

            // Service History List
            Expanded(child: _buildServiceHistoryList()),

            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFF61758A)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Padding(
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
                    'Filter',
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
    );
  }

  Widget _buildServiceHistoryList() {
    final items = filteredItems;

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No service history found',
          style: TextStyle(fontSize: 16, color: Color(0xFF61758A)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildServiceHistoryCard(item);
      },
    );
  }

  Widget _buildServiceHistoryCard(ServiceHistoryItem item) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF4CAF50).withOpacity(0.1),
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
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F2F5), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard, 'Dashboard', false),
            _buildNavItem(1, Icons.work, 'Manage Jobs', false),
            _buildNavItem(2, Icons.history, 'History', true),
            _buildNavItem(3, Icons.person, 'Profile', false),
          ],
        ),
      ),
    );
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
}
