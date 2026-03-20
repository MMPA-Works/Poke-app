import 'package:flutter/material.dart';

import 'pages/login_page.dart'; // Changed to import the login page

void main() {
  runApp(const HAUMonstersApp());
}

class HAUMonstersApp extends StatelessWidget {
  const HAUMonstersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F7A5A),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'HAUMonsters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7F4),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      // Set the home page to LoginPage so players must log in
      home: const LoginPage(), 
    );
  }
}