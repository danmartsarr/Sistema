import 'package:deepmicroplastic/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const OceanScannerApp());
}

class OceanScannerApp extends StatelessWidget {
  const OceanScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanner Multiespectral',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        primaryColor: Colors.cyanAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
