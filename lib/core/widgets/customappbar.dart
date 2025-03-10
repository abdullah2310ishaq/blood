import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor, // ✅ Primary color background
      elevation: 2,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centered title
        children: [
          // ✅ Left Side: App Logo
          Image.asset(
            'assets/appbarlogo.jpg', // Make sure this image exists in assets
            height: 40, // Adjust height for good UI
          ),
          const SizedBox(width: 10), // Spacing

          // ✅ Center: Title
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
      centerTitle: true, // Ensures title stays centered
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(60); // ✅ Standard AppBar Height
}
