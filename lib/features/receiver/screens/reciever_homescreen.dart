import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/customappbar.dart'; // ✅ Import Custom AppBar
// ✅ Import Custom Navbar
import '../widgets/navbar.dart';
import 'find_donor_screen.dart';
import 'receiverrequestscreen.dart';
import 'editprofile.dart';

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
      appBar: const CustomAppBar(), // ✅ Use Custom AppBar
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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

            // ✅ Banner Image (commonhome.jpg)
            Center(
              child: Image.asset(
                'assets/commonhome.jpg', // Ensure image exists in assets folder
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Buttons Section
            Column(
              children: [
                // 🔴 Find Donors Button
                _buildActionButton(
                  label: "Find Donors",
                  icon: 'assets/donor.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ReceiverFindDonorsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 📝 View Requests Button
                _buildActionButton(
                  label: "View Requests",
                  icon: 'assets/donor.png', // Add this image in assets
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReceiverRequestsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 👤 Edit Profile Button
                _buildActionButton(
                  label: "Edit Profile",
                  icon: 'assets/donor.png', // Add this image in assets
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ReceiverEditProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // ✅ Custom Bottom Navigation Bar
      bottomNavigationBar: ReceiverNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // ✅ Helper Function to Create Buttons
  Widget _buildActionButton({
    required String label,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent, // Primary color
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Image.asset(
          icon, // Ensure the image exists in assets
          height: 30,
        ),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
