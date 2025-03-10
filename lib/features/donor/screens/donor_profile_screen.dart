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
  bool isAvailable = true;
  String profilePicUrl = "";

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
          isAvailable = doc.get('isAvailable') ?? true;
          profilePicUrl = doc.get('profilePic') ?? "";
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

  // ✅ Upload Profile Image to Firebase Storage
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      User? user = _authService.getCurrentUser();
      if (user != null) {
        try {
          String filePath = "profile_pics/${user.uid}.jpg";
          Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
          await storageRef.putFile(_imageFile!);
          String downloadUrl = await storageRef.getDownloadURL();

          // Update profile pic in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({"profilePic": downloadUrl});

          setState(() {
            profilePicUrl = downloadUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated!")),
          );
        } catch (e) {
          print("Error uploading profile picture: $e");
        }
      }
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
          "isAvailable": isAvailable,
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
                              onTap: _pickImage,
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
                      validator: (val) =>
                          val!.isEmpty ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 16),

                    // ✅ Contact Field
                    TextFormField(
                      initialValue: contact,
                      decoration: const InputDecoration(
                        labelText: "Contact",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => contact = val,
                      validator: (val) =>
                          val!.isEmpty ? "Enter your contact" : null,
                    ),
                    const SizedBox(height: 16),

                    // ✅ City Field
                    TextFormField(
                      initialValue: city,
                      decoration: const InputDecoration(
                        labelText: "City",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => city = val,
                      validator: (val) =>
                          val!.isEmpty ? "Enter your city" : null,
                    ),
                    const SizedBox(height: 16),

                    // ✅ Blood Group Dropdown
                    const Text("Blood Group"),
                    DropdownButtonFormField<String>(
                      value: bloodGroup,
                      items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                          .map((group) => DropdownMenuItem(
                              value: group, child: Text(group)))
                          .toList(),
                      onChanged: (value) => setState(() => bloodGroup = value!),
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
                    const SizedBox(height: 24),

                    // ✅ Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveProfile,
                        child: const Text("Save Profile",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
