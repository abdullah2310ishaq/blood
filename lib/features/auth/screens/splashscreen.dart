import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your IntroScreen, DonorHomeScreen, ReceiverHomeScreen, etc.
import 'intro.dart';
import '../../donor/screens/donor_homescreen.dart';
import '../../receiver/screens/reciever_homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  // Wait for 3-5 seconds, then check if user is logged in
  Future<void> _checkUser() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Show splash for a few seconds

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // No user => go to Intro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    } else {
      // There's a logged-in user => check role & go to appropriate screen
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final role = doc.get('role');
        if (role == 'donor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DonorHomeScreen()),
          );
        } else if (role == 'receiver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ReceiverHomeScreen()),
          );
        } else {
          // If role is missing or unknown, we can show Intro or Login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const IntroScreen()),
          );
        }
      } else {
        // user doc doesn't exist => fallback to Intro
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/logo.jpg', width: 150),
      ),
    );
  }
}
