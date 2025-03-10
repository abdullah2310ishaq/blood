import 'package:flutter/material.dart';
import '../widgets/donor_info_card.dart';

class DonorDashboardScreen extends StatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Blood Donation Banner Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      12), // Rounded corners for a smooth UI
                  child: Image.asset(
                    'assets/commonhome.jpg', // Replace with your image
                    width: double.infinity,
                    height: 160, // Adjust height
                    fit: BoxFit.cover, // Ensures it covers the width
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Title
              const Text(
                "Welcome to Your Dashboard",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ✅ Donor Info Card (Now Looks More Professional)
              const DonorInfoCard(),
            ],
          ),
        ),
      ),
    );
  }
}
