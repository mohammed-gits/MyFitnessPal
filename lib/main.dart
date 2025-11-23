import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';

// Team Members: Mohammed Osman and Ali Lamaa

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFitnessApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Home(),
    );
  }
}
