import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/providers/donor.dart';
import '../../../core/widgets/customappbar.dart';
import 'donor_dashboard.dart';
import 'donation_form_screen.dart';
import 'donor_profile_screen.dart';
import 'see_donationrequests.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  _DonorHomeScreenState createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<DonorProvider>(context, listen: false).loadDonorData();
  }

  // ✅ Logout Function
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
        context, "/login"); // Redirect to login screen
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DonorDashboardScreen(), // 🏠 Home Page (Welcome, Donor!)
      const DonorBloodRequestsScreen(), // 📜 See Blood Requests from Receivers
      const DonorFormScreen(), // 🩸 Blood Donation Form
      const DonorProfileScreen(), // 👤 Edit Profile
    ];

    return Scaffold(
      appBar: CustomAppBar(),
      body: screens[_currentIndex], // Show selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Keeps all icons visible
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Requests",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Donate",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
