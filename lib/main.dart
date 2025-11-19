import 'package:flutter/material.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrackApp',
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
