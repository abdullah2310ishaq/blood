import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/customappbar.dart'; // Custom AppBar
import '../widgets/navbar.dart';
import 'find_donor_screen.dart';
import 'receiverrequestscreen.dart';
import 'editprofile.dart';
import 'receiver_create_request.dart'; // For 'Request Blood' Screen
import '../../../core/constants/colors.dart'; // Your color constants

class ReceiverHomeScreen extends StatefulWidget {
  const ReceiverHomeScreen({super.key});

  @override
  _ReceiverHomeScreenState createState() => _ReceiverHomeScreenState();
}

class _ReceiverHomeScreenState extends State<ReceiverHomeScreen> {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // ✅ Using Custom AppBar
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Welcome Message
            Text(
              "Welcome, ${user?.displayName ?? "Receiver"}!",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Banner Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/commonhome.jpg',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 ROW 1: Request Blood & Find Donor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallCard(
                  label: "Request Blood",
                  imagePath: "assets/edit1.png",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ReceiverCreateRequestScreen(),
                      ),
                    );
                  },
                ),
                _buildSmallCard(
                  label: "Find Donor",
                  imagePath: "assets/edit.png",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceiverFindDonorsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🔹 ROW 2: View Requests & Profile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallCard(
                  label: "View Requests",
                  imagePath: "assets/requests.png", // Replace with your asset
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceiverRequestsScreen(),
                      ),
                    );
                  },
                ),
                _buildSmallCard(
                  label: "Profile",
                  imagePath: "assets/profile.png", // Replace with your asset
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceiverEditProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper Function for 2x2 Cards
  Widget _buildSmallCard({
    required String label,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor, // Soft creamy white (or your chosen color)
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 40),
            const SizedBox(height: 13),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
