import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cozy Community',
      debugShowCheckedModeBanner: false,
      theme: CozyTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}