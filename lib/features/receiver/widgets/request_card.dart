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
  void _callContact(BuildContext context) async {
    final url = "tel:$contact";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to open Dialer!")),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ Blood Group Badge
          Container(
            width: 55,
            height: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(10),
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

          // ✅ Donor Details (Name + Availability)
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
                Row(
                  children: [
                    Icon(
                      isAvailable ? Icons.check_circle : Icons.cancel,
                      color: isAvailable ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAvailable ? "Available" : "Not Available",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ Quick Actions: Copy & Call Buttons
          Row(
            children: [
              // 📋 Copy Button
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.black),
                onPressed: () => _copyContact(context),
                tooltip: "Copy Number",
              ),

          
              // ➡ View Details
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onPressed: onViewDetails, // Navigate to detailed page
              ),
            ],
          ),
        ],
      ),
    );
  }
}
