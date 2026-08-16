import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const Hakim());
}

class Hakim extends StatelessWidget {
  const Hakim({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hakim',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF123F78),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}