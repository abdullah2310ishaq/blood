import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorCard extends StatelessWidget {
  final String name;
  final String age;
  final String bloodGroup;
  final String location;
  final String distance;
  final String contact;
  final String timeLimit;
  final String profilePic;

  const DonorCard({
    super.key,
    required this.name,
    required this.age,
    required this.bloodGroup,
    required this.location,
    required this.distance,
    required this.contact,
    required this.timeLimit,
    required this.profilePic,
  });

  // ✅ Opens Phone Dialer
  void _makePhoneCall(String contact) async {
    final Uri launchUri = Uri(scheme: 'tel', path: contact);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Could not launch $contact");
    }
  }

  // ✅ Opens Share Sheet
  void _shareDonorInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Share donor info: $name, $contact")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // ✅ Profile Picture + Blood Group
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red[100],
                      backgroundImage:
                          profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                      child: profilePic.isEmpty
                          ? const Icon(Icons.person, size: 30, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bloodGroup,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // ✅ Donor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$name, $age yr old",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.directions_walk, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("$distance Km"),
                        ],
                      ),
                    ],
                  ),
                ),

                // ✅ Call Button
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _makePhoneCall(contact),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ✅ Share & Request Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () => _shareDonorInfo(context),
                  icon: const Icon(Icons.share, color: Colors.grey),
                  label: const Text("Share", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Request sent to $name")),
                    );
                  },
                  icon: const Icon(Icons.request_page),
                  label: const Text("Request"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
