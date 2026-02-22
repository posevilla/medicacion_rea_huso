import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(const MedicacionReaHusoApp());
}

class MedicacionReaHusoApp extends StatelessWidget {
  const MedicacionReaHusoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicación REA HUSO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const SplashPage(),
    );
  }
}
