import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/auth_service.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  _DonorProfileScreenState createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  String name = "";
  String contact = "";
  String city = "";
  String bloodGroup = "A+";
  int age = 18;
  String gender = "Male";
  DateTime? lastDonationDate;
  bool isAvailable = true; // ✅ Availability Status
  String profilePicUrl = "";
  String additionalNotes = "";

  bool isLoading = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ✅ Load User Data from Firestore
  Future<void> _loadUserProfile() async {
    try {
      User? user = _authService.getCurrentUser();
      if (user == null) {
        print("User is not logged in.");
        return;
      }

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          name = doc.get('name') ?? "";
          contact = doc.get('contact') ?? "";
          city = doc.get('city') ?? "";
          bloodGroup = doc.get('bloodGroup') ?? "A+";
          age = doc.get('age') ?? 18;
          gender = doc.get('gender') ?? "Male";
          lastDonationDate = doc.get('lastDonationDate') != null
              ? DateTime.parse(doc.get('lastDonationDate'))
              : null;
          isAvailable =
              doc.get('isAvailable') ?? true; // ✅ Load Availability Status
          profilePicUrl = doc.get('profilePic') ?? "";
          additionalNotes = doc.get('additionalNotes') ?? "";
          isLoading = false;
        });
      } else {
        print("Firestore document does not exist or has no data.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Save Updated Profile Data
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _authService.getCurrentUser();
        if (user == null) return;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          "name": name,
          "contact": contact,
          "city": city,
          "bloodGroup": bloodGroup,
          "age": age,
          "gender": gender,
          "lastDonationDate": lastDonationDate?.toIso8601String(),
          "isAvailable": isAvailable, // ✅ Save Availability Status
          "additionalNotes": additionalNotes,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      } catch (e) {
        print("Error saving profile data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donor Profile"),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ✅ Profile Image
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: profilePicUrl.isNotEmpty
                                ? NetworkImage(profilePicUrl) as ImageProvider
                                : null,
                            child: profilePicUrl.isEmpty
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                final pickedFile = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    _imageFile = File(pickedFile.path);
                                  });

                                  User? user = _authService.getCurrentUser();
                                  if (user != null) {
                                    try {
                                      String filePath =
                                          "profile_pics/${user.uid}.jpg";
                                      Reference storageRef = FirebaseStorage
                                          .instance
                                          .ref()
                                          .child(filePath);
                                      await storageRef.putFile(_imageFile!);
                                      String downloadUrl =
                                          await storageRef.getDownloadURL();

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .update({"profilePic": downloadUrl});

                                      setState(() {
                                        profilePicUrl = downloadUrl;
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Profile picture updated!")),
                                      );
                                    } catch (e) {
                                      print(
                                          "Error uploading profile picture: $e");
                                    }
                                  }
                                }
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18,
                                child:
                                    Icon(Icons.camera_alt, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✅ Name Field
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => name = val,
                    ),
                    const SizedBox(height: 16),

                    // ✅ Age Field
                    TextFormField(
                      initialValue: age.toString(),
                      decoration: const InputDecoration(
                        labelText: "Age",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => age = int.tryParse(val) ?? 18,
                    ),
                    const SizedBox(height: 16),

                    // ✅ Gender Dropdown
                    const Text("Gender"),
                    DropdownButtonFormField<String>(
                      value: gender,
                      items: ["Male", "Female"]
                          .map((gen) => DropdownMenuItem(
                                value: gen,
                                child: Text(gen),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => gender = value!),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Availability Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Available to Donate?"),
                        Switch(
                          value: isAvailable,
                          activeColor: primaryColor,
                          onChanged: (value) =>
                              setState(() => isAvailable = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ✅ Last Donation Date Picker
                    const Text("Last Donation Date"),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() => lastDonationDate = pickedDate);
                        }
                      },
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: lastDonationDate == null
                              ? "Select Date"
                              : "${lastDonationDate!.day}/${lastDonationDate!.month}/${lastDonationDate!.year}",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Additional Notes
                    TextFormField(
                      initialValue: additionalNotes,
                      decoration: const InputDecoration(
                        labelText: "Additional Notes (Optional)",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => additionalNotes = val,
                    ),
                    const SizedBox(height: 24),

                    // ✅ Save Button
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text("Save Profile"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
