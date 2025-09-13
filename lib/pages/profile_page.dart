import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  SizedBox(width: 48), // Spacer for centering
                  Expanded(
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
                  SizedBox(width: 48), // Spacer for centering
                ],
              ),
            ),

            // Profile Information
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: Color(0xFFF0F2F5),
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: Color(0xFF61758A),
                    ),
                  ),
                  SizedBox(height: 16),

                  // User Name
                  Text(
                    'Ethan Carter',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121417),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Role
                  Text(
                    'Mechanic',
                    style: TextStyle(fontSize: 16, color: Color(0xFF61758A)),
                  ),
                  SizedBox(height: 4),

                  // Email
                  Text(
                    'ethan.carter@email.com',
                    style: TextStyle(fontSize: 16, color: Color(0xFF61758A)),
                  ),
                ],
              ),
            ),

            // Account Section
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Title
                Padding(
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
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFF0F2F5),
                    child: Icon(
                      Icons.phone,
                      color: Color(0xFF121417),
                      size: 24,
                    ),
                  ),
                  title: Text('Phone Number'),
                  subtitle: Text('+1 (555) 123-4567'),
                ),

                // Email
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFF0F2F5),
                    child: Icon(
                      Icons.email,
                      color: Color(0xFF121417),
                      size: 24,
                    ),
                  ),
                  title: Text('Email'),
                  subtitle: Text('ethan.carter@email.com'),
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
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 2),
    );
  }
}
