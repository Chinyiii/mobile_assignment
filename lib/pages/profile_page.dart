import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assignment/auth/auth_service.dart';
import 'package:mobile_assignment/main.dart'; // supabase instance
import '../services/supabase_service.dart';
import '../widgets/bottom_navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => loading = true);

    final email = authService.getCurrentUserEmail();
    if (email == null) {
      setState(() => loading = false);
      return;
    }

    try {
      // fetch name, email, phone, address, profile picture
      final response = await supabase
          .from('users')
          .select('name, email, phone_number, address, profile_pic')
          .eq('email', email)
          .maybeSingle();

      if (mounted) {
        setState(() {
          profile = response;
        });
      }
    } catch (e) {
      // optionally handle error
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await authService.signOut();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
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
    if (loading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const SizedBox(width: 48),
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
                  SizedBox(
                    width: 48,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: _showLogoutDialog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 32),
                      _buildAccountDetails(),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 2),
    );
  }

  Widget _buildProfileHeader() {
    final name = profile?['name'] ?? "Unknown Name";
    final profilePicBase64 = profile?['profile_pic'] as String?;

    ImageProvider avatar;
    if (profilePicBase64 != null && profilePicBase64.isNotEmpty) {
      try {
        avatar = MemoryImage(base64Decode(profilePicBase64));
      } catch (_) {
        avatar = const AssetImage("assets/images/default_avatar.png");
      }
    } else {
      avatar = const AssetImage("assets/images/default_avatar.png");
    }

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 64,
            backgroundColor: const Color(0xFFF0F2F5),
            backgroundImage: avatar,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails() {
    final currentEmail = profile?['email'] ?? "Unknown Email";
    final phone = profile?['phone_number'] ?? "Not set";
    final address = profile?['address'] ?? "Not set";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121417),
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailItem(Icons.email, 'Email', currentEmail),
        const SizedBox(height: 16),
        _buildDetailItem(Icons.phone, 'Phone Number', phone),
        const SizedBox(height: 16),
        _buildDetailItem(Icons.home, 'Address', address),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF61758A)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF121417),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF61758A)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, '/edit_profile');
              _loadProfile();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF121417),
              backgroundColor: const Color(0xFFDEE8F2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/reset_password');
            },
            icon: const Icon(Icons.lock_reset),
            label: const Text('Change Password'),
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF121417),
              backgroundColor: const Color(0xFFF2F2F5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
