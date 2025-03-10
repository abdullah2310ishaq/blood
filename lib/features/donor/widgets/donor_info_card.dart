import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/providers/donor.dart';

class DonorInfoCard extends StatefulWidget {
  const DonorInfoCard({super.key});

  @override
  State<DonorInfoCard> createState() => _DonorInfoCardState();
}

class _DonorInfoCardState extends State<DonorInfoCard> {
  @override
  Widget build(BuildContext context) {
    final donorProvider = Provider.of<DonorProvider>(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white, // Improved contrast
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Profile Section
            Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: donorProvider.profilePicUrl.isNotEmpty
                      ? NetworkImage(donorProvider.profilePicUrl)
                      : null,
                  child: donorProvider.profilePicUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),

                // Donor Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donorProvider.name.isNotEmpty
                            ? donorProvider.name
                            : "No Name Provided",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        donorProvider.contact.isNotEmpty
                            ? donorProvider.contact
                            : "No Contact Info",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),

                      // ✅ Blood Group Display
                      Chip(
                        label: Text(
                          donorProvider.bloodGroup.isNotEmpty
                              ? donorProvider.bloodGroup
                              : "No Blood Group",
                          style: const TextStyle(fontSize: 14),
                        ),
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Additional Donor Information
            Text(
              "Age: ${donorProvider.age}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Gender: ${donorProvider.gender}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "City: ${donorProvider.city}",
              style: const TextStyle(fontSize: 16),
            ),
            if (donorProvider.lastDonationDate != null)
              Text(
                "Last Donation: ${donorProvider.lastDonationDate!.day}/${donorProvider.lastDonationDate!.month}/${donorProvider.lastDonationDate!.year}",
                style: const TextStyle(fontSize: 16),
              ),
            if (donorProvider.additionalNotes.isNotEmpty)
              Text(
                "Notes: ${donorProvider.additionalNotes}",
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),

            const SizedBox(height: 12),

            // ✅ Availability Toggle Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  donorProvider.isAvailable
                      ? "Available to Donate"
                      : "Not Available",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        donorProvider.isAvailable ? Colors.green : Colors.red,
                  ),
                ),
                Switch(
                  value: donorProvider.isAvailable,
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.redAccent.withOpacity(0.5),
                  onChanged: (value) async {
                    String? uid =
                        FirebaseAuth.instance.currentUser?.uid; // ✅ FIXED HERE
                    if (uid != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({"isAvailable": value});

                      donorProvider.isAvailable = value;
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
