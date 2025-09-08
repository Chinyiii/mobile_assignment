import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'job_management_page.dart';
import 'service_history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // Profile tab is selected

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
    } else if (index == 2) {
      // Navigate to Service History page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ServiceHistoryPage()),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout functionality
                // For now, just show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(width: 48), // Spacer for centering
                  const Expanded(
                    child: Text(
                      'Profile',
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

            // Profile Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(64),
                      color: const Color(0xFFF0F2F5),
                    ),
                    child: const Icon(Icons.person, size: 64, color: Color(0xFF61758A)),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  const Text(
                    'Ethan Carter',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121417),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Role
                  const Text(
                    'Mechanic',
                    style: TextStyle(fontSize: 16, color: Color(0xFF61758A)),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  const Text(
                    'ethan.carter@email.com',
                    style: TextStyle(fontSize: 16, color: Color(0xFF61758A)),
                  ),
                ],
              ),
            ),

            // Account Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Title
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121417),
                    ),
                  ),
                ),

                // Phone Number
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF0F2F5),
                        ),
                        child: const Icon(Icons.phone, color: Color(0xFF121417), size: 24),
                      ),

                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF121417),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '+1 (555) 123-4567',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF61758A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF0F2F5),
                        ),
                        child: const Icon(Icons.email, color: Color(0xFF121417), size: 24),
                      ),

                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF121417),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ethan.carter@email.com',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF61758A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: _showLogoutDialog,
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF0F2F5),
                  ),
                  child: const Center(
                    child: Text(
                      'Logout',
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

            const Spacer(),

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
}