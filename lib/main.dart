import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'themes/app_theme.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amasandería La Lela',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // ¡Llamamos al tema modularizado!
      home: const DashboardScreen(), 
    );
  }
}