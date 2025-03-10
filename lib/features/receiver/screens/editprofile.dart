import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/colors.dart';

class ReceiverEditProfileScreen extends StatefulWidget {
  const ReceiverEditProfileScreen({super.key});

  @override
  _ReceiverEditProfileScreenState createState() =>
      _ReceiverEditProfileScreenState();
}

class _ReceiverEditProfileScreenState extends State<ReceiverEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String contact = "";
  String city = "";
  String profilePicUrl = "";
  bool isLoading = true;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadReceiverData();
  }

  // ✅ Load Receiver Data from Firestore
  Future<void> _loadReceiverData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      setState(() {
        name = doc.get('name') ?? "";
        contact = doc.get('contact') ?? "";
        city = doc.get('city') ?? "";
        profilePicUrl = doc.get('profilePic') ?? "";
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

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String filePath = "profile_pics/${user.uid}.jpg";
        Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
        await storageRef.putFile(_imageFile!);
        String downloadUrl = await storageRef.getDownloadURL();

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
      }
    }
  }

  // ✅ Save Profile Updates
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        "name": name,
        "contact": contact,
        "city": city,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
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
                                ? NetworkImage(profilePicUrl)
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
