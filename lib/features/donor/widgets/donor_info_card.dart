import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/providers/donor.dart';

class DonorInfoCard extends StatefulWidget {
  const DonorInfoCard({super.key});

  @override
  State<DonorInfoCard> createState() => _DonorInfoCardState();
}

class _DonorInfoCardState extends State<DonorInfoCard> {
  // ✅ Toggle Availability in Firestore

  @override
  Widget build(BuildContext context) {
    final donorProvider = Provider.of<DonorProvider>(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: secondaryColor, // Background color
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            // ✅ Profile Picture (Left)
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage: donorProvider.profilePicUrl.isNotEmpty
                  ? NetworkImage(donorProvider.profilePicUrl)
                  : null,
              child: donorProvider.profilePicUrl.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12), // Spacing

            // ✅ Donor Details (Center)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Donor Name
                  Text(
                    donorProvider.name.isNotEmpty
                        ? donorProvider.name
                        : "No Name Provided",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  // Contact
                  Text(
                    donorProvider.contact.isNotEmpty
                        ? donorProvider.contact
                        : "No Contact Info",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 6),

                  // ✅ Blood Group Chip
                  Chip(
                    label: Text(
                      donorProvider.bloodGroup.isNotEmpty
                          ? donorProvider.bloodGroup
                          : "No Blood Group",
                      style: const TextStyle(fontSize: 14),
                    ),
                    backgroundColor: primaryColor.withOpacity(0.1),
                  ),
                ],
              ),
            ),

            // ✅ Toggle Button for Availability (Right)
            Column(
              children: [
                Text(
                  donorProvider.isAvailable ? "Available" : "Inactive",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: donorProvider.isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              
              ],
            ),
          ],
        ),
      ),
    );
  }
}
