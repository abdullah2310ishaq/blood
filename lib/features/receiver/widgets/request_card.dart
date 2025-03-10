import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class DonorCard extends StatelessWidget {
  final String name;
  final String bloodGroup;
  final bool isAvailable;
  final String contact;
  final String? profilePic;
  final VoidCallback onViewDetails; // ✔ For navigating to DetailedDonorPage

  const DonorCard({
    super.key,
    required this.name,
    required this.bloodGroup,
    required this.isAvailable,
    required this.contact,
    this.profilePic,
    required this.onViewDetails,
  });

  // ✅ Open Phone Dialer
  void _makePhoneCall(BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: contact);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Could not launch phone dialer.")),
      );
    }
  }

  // ✅ Copy Contact Number
  void _copyContact(BuildContext context) {
    Clipboard.setData(ClipboardData(text: contact));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Phone number copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Blood Group
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              bloodGroup,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Donor Name & Availability
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : "N/A",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isAvailable ? "✅ Available" : "❌ Not Available",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () => _makePhoneCall(context),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.black),
            onPressed: () => _copyContact(context),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onPressed: onViewDetails, // Navigate to detailed page
          ),
        ],
      ),
    );
  }
}
