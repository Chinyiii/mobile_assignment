import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/dashboard_page.dart';
import 'package:mobile_assignment/pages/forgot_password.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/reset_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uehfxybntoeblhnjtynb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVlaGZ4eWJudG9lYmxobmp0eW5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MjQ5MTAsImV4cCI6MjA3MzAwMDkxMH0.tB49dyoK9Sse0MjwmcF-1lATPuDhSRGnvoiHVER5RWw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF121417)),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),

      // Start at login
      initialRoute: '/login',

      // Routes
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfilePage(),
        '/edit_profile': (context) => const EditProfilePage(),
        '/reset_password': (context) => const ResetPasswordPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
      },
    );
  }
}
