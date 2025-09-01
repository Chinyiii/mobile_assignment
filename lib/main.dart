import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF121417)),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const DashboardPage(),
    );
  }
}
