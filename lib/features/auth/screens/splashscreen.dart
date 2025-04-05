import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bloood_donation_app/core/providers/auth_provider.dart';
import 'package:bloood_donation_app/features/auth/screens/intro_screen.dart';
import 'package:bloood_donation_app/features/donor/screens/donor_homescreen.dart';
import 'package:bloood_donation_app/features/receiver/screens/reciever_homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));
    
    if (authProvider.isAuthenticated) {
      await authProvider.initUser();
      if (authProvider.user != null) {
        if (!mounted) return;
        
        if (authProvider.user!.role == 'donor') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DonorHomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ReceiverHomeScreen()),
          );
        }
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
      }
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.bloodtype,
                color: Colors.red,
                size: 100,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Blood Donation App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

