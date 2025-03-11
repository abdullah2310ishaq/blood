import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../constants/colors.dart'; // Ensure this file exists
import '../services/auth_service.dart'; // Import AuthService

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor, // Primary color background
      elevation: 4, // Slight shadow for depth
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centered title
        children: [
          // ✅ App Logo
          Image.asset(
            'assets/appbarlogo.jpg', // Ensure this image exists in assets
            height: 40, // Adjust height for a good UI
          ),
          const SizedBox(width: 10), // Spacing

          // ✅ App Title
          const Text(
            "Blood Donation",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for contrast
            ),
          ),
        ],
      ),
      centerTitle: true,

      // ✅ Logout Button (Top Right)
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => _showLogoutConfirmation(context),
        ),
      ],
    );
  }

  // ✅ Logout Confirmation Modal with Soft Creamy White Background
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Smooth rounded edges
          ),
          backgroundColor: const Color(0xFFFFF5E1), // Soft creamy white color
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Title
                const Text(
                  "Confirm Logout",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Soft black text
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ Message
                const Text(
                  "Are you sure you want to log out?",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // ✅ Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ❌ Cancel Button
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context), // Close the dialog
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Colors.grey.shade300, // Light grey for contrast
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.black87)),
                    ),

                    // ✅ Logout Button
                    ElevatedButton(
                      onPressed: () async {
                        await _logoutUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Logout button color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Logout",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Logout Function Using AuthService (with Proper Redirection)
  Future<void> _logoutUser(BuildContext context) async {
    try {
      await AuthService().signOut(); // Call logout function from AuthService
      Navigator.pop(context); // Close dialog

      // ✅ Ensure complete logout and prevent back navigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const LoginScreen()), // Replace with your actual login screen
        (route) => false, // Removes all previous routes
      );
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(60); // Standard AppBar Height
}
