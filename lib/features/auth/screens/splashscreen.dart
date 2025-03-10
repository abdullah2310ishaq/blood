import 'package:bloood_donation_app/features/auth/screens/intro.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToIntro();
  }

  void _navigateToIntro() async {
    await Future.delayed(const Duration(seconds: 5)); // Show splash for 5 sec
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const IntroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Center(
        child: Image.asset('assets/logo.jpg', width: 150), // Logo centered
      ),
    );
  }
}
