import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/service_history_page.dart';
import '../pages/profile_page.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNavigationBar({super.key, required this.selectedIndex});

  void _onItemTapped(int index, BuildContext context) {
    if (index == selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const ServiceHistoryPage();
        break;
      case 2:
        page = const ProfilePage();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F2F5), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.dashboard, 'Dashboard'),
            _buildNavItem(context, 1, Icons.history, 'History'),
            _buildNavItem(context, 2, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
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
}
