import 'package:flutter/material.dart';

class ReceiverDashboardScreen extends StatelessWidget {
  const ReceiverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Welcome, Receiver!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
