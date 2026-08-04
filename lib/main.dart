import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const HakimApp());
}

class HakimApp extends StatelessWidget {
  const HakimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Hakim",

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: LoginScreen(),
    );
  }
}