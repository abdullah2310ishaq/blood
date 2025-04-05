import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bloood_donation_app/core/providers/auth_provider.dart';
import 'package:bloood_donation_app/core/providers/donor_provider.dart';
import 'package:bloood_donation_app/features/donor/screens/donor_profile_screen.dart';
import 'package:bloood_donation_app/features/donor/screens/see_donationrequests.dart';
import 'package:bloood_donation_app/features/donor/screens/my_donations_screen.dart';
import 'package:bloood_donation_app/features/auth/screens/intro_screen.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initDonor();
  }

  Future<void> _initDonor() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final donorProvider = Provider.of<DonorProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await donorProvider.initDonor(authProvider.user!.id);
      if (donorProvider.donor == null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DonorProfileScreen()),
        );
      } else {
        // Fetch my donations
        await donorProvider.fetchMyDonations();
        
        // Update location if sharing is enabled
        if (donorProvider.donor!.shareLocation) {
          await donorProvider.updateDonorLocation();
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final donorProvider = Provider.of<DonorProvider>(context);
    
    // If user or donor is null, show loading
    if (authProvider.user == null || donorProvider.donor == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> pages = [
      _buildDashboard(),
      const SeeDonationRequestsScreen(),
      const MyDonationsScreen(),
      _buildProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'My Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboard() {
    final donorProvider = Provider.of<DonorProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        await donorProvider.fetchMyDonations();
        if (donorProvider.donor!.shareLocation) {
          await donorProvider.updateDonorLocation();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red.shade100,
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${authProvider.user!.name}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Blood Type: ${donorProvider.donor!.bloodType}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Status: ${donorProvider.donor!.isAvailable ? 'Available' : 'Not Available'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: donorProvider.donor!.isAvailable
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Switch(
                          value: donorProvider.donor!.isAvailable,
                          activeColor: Colors.green,
                          onChanged: (value) async {
                            await donorProvider.toggleAvailability();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Location Sharing: ${donorProvider.donor!.shareLocation ? 'On' : 'Off'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: donorProvider.donor!.shareLocation
                                  ? Colors.blue
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Switch(
                          value: donorProvider.donor!.shareLocation,
                          activeColor: Colors.blue,
                          onChanged: (value) async {
                            await donorProvider.toggleLocationSharing();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Impact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Last Donation',
                    donorProvider.donor!.lastDonationDate.toString().substring(0, 10),
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Blood Type',
                    donorProvider.donor!.bloodType,
                    Icons.bloodtype,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Donations',
                    donorProvider.myDonations.where((d) => d.status == 'completed').length.toString(),
                    Icons.favorite,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Pending Donations',
                    donorProvider.myDonations.where((d) => d.status == 'accepted').length.toString(),
                    Icons.pending_actions,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Blood Donation Facts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFactCard(
              'One donation can save up to three lives!',
              Icons.favorite,
            ),
            const SizedBox(height: 12),
            _buildFactCard(
              'You can donate blood every 56 days.',
              Icons.access_time,
            ),
            const SizedBox(height: 12),
            _buildFactCard(
              'Blood cannot be manufactured – it can only come from donors.',
              Icons.science,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactCard(String fact, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.red,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                fact,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return const DonorProfileScreen();
  }
}

