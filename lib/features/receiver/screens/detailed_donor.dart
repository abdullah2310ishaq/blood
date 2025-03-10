import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailedDonorPage extends StatelessWidget {
  final String name;
  final String age;
  final String bloodGroup;
  final String location;
  final String contact;
  final String? profilePic;
  final bool isAvailable;
  final String lastDonationDate;
  final String notes;

  const DetailedDonorPage({
    super.key,
    required this.name,
    required this.age,
    required this.bloodGroup,
    required this.location,
    required this.contact,
    this.profilePic,
    required this.isAvailable,
    required this.lastDonationDate,
    required this.notes,
  });

  // ✅ Call Donor
  Future<void> callDonor(String phoneNumber) async {
    // Check & Request Call Permission
    PermissionStatus status = await Permission.phone.request();
    if (status.isGranted) {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint("❌ Could not launch phone dialer.");
      }
    } else {
      debugPrint("❌ Call Permission Denied.");
    }
  }

  // ✅ WhatsApp Chat
  Future<void> chatOnWhatsApp(String phoneNumber, String donorName) async {
    // Format number (remove +, spaces, or dashes)
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    String message =
        "Hello $donorName, I found you on the Blood Donation app. Are you available?";
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      debugPrint("❌ Could not open WhatsApp.");
    }
  }

  // ✅ Share Donor Info
  void _shareDonorInfo() async {
    final String shareMessage = "Donor Details:\n"
        "Name: $name\n"
        "Age: $age\n"
        "Blood Group: $bloodGroup\n"
        "Location: $location\n"
        "Contact: $contact\n"
        "Last Donation: ${(lastDonationDate.isNotEmpty && lastDonationDate != 'N/A') ? lastDonationDate.split(' ')[0] : 'N/A'}\n"
        "Availability: ${isAvailable ? 'Available' : 'Not Available'}";

    final Uri shareUrl =
        Uri.parse("https://wa.me/?text=${Uri.encodeComponent(shareMessage)}");
    if (await canLaunchUrl(shareUrl)) {
      await launchUrl(shareUrl);
    } else {
      debugPrint("❌ Could not open WhatsApp for sharing.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We'll build our own top bar and background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFEBEE), // Light cream/pink
              Color(0xFFFFCDD2), // Subtle pink
              Colors.white, // to a whiter shade at the bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Custom top bar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.redAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        "Donor Details",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // empty space for symmetry
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ✅ Profile Image (center)
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.red[100],
                    backgroundImage: (profilePic?.isNotEmpty ?? false)
                        ? NetworkImage(profilePic!)
                        : null,
                    child: (profilePic == null || profilePic!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),

                  const SizedBox(height: 24),

                  // ✅ Name & Age
                  Text(
                    "$name, $age yrs",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // ✅ Blood Group
                  Chip(
                    label: Text(
                      bloodGroup,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    backgroundColor: Colors.red[50],
                  ),

                  const SizedBox(height: 6),

                  // ✅ Availability
                  Text(
                    isAvailable
                        ? "✅ Available for Donation"
                        : "❌ Not Available",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Additional Info
                  if (location.isNotEmpty)
                    InfoRow(
                      icon: Icons.location_on,
                      label: "Location",
                      value: location,
                    ),
                  if (lastDonationDate.isNotEmpty && lastDonationDate != "N/A")
                    InfoRow(
                      icon: Icons.history,
                      label: "Last Donation",
                      value: lastDonationDate.split(' ')[0],
                    ),
                  if (notes.isNotEmpty)
                    InfoRow(
                      icon: Icons.note,
                      label: "Notes",
                      value: notes,
                      italic: true,
                    ),

                  const SizedBox(height: 24),

                  // ✅ Contact
                  Text(
                    "Contact: $contact",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // ✅ Action Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        onPressed: () => callDonor(contact), // ✅ Fix here
                        icon: const Icon(Icons.phone),
                        label: const Text("Call Now",
                            style: TextStyle(fontSize: 16)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        onPressed: () =>
                            chatOnWhatsApp(contact, name), // ✅ Fix here
                        icon: const Icon(Icons.call),
                        label: const Text("WhatsApp",
                            style: TextStyle(fontSize: 16)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        onPressed: _shareDonorInfo, // no parameters needed
                        icon: const Icon(Icons.share),
                        label:
                            const Text("Share", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Helper Widget for Single-Row Info
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool italic;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.redAccent),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
