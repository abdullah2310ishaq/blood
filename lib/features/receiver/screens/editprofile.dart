import 'dart:io';
import 'package:bloood_donation_app/core/widgets/customappbar.dart';
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

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

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

  // ✅ Remove Profile Image
  Future<void> _removeImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({"profilePic": ""});

    setState(() {
      profilePicUrl = "";
      _imageFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile picture removed!")),
    );
  }

  // ✅ Save Profile Updates
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
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
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ✅ Profile Image Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: profilePicUrl.isNotEmpty
                                ? NetworkImage(profilePicUrl)
                                : null,
                            child: profilePicUrl.isEmpty
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          // Change & Remove Options
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 18,
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.black),
                                  ),
                                ),
                                if (profilePicUrl.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: _removeImage,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red[100],
                                      radius: 18,
                                      child: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✅ Name Field
                    _buildTextField(
                      label: "Name",
                      hintText: "Enter your name",
                      initialValue: name,
                      onChanged: (val) => name = val,
                    ),

                    // ✅ Contact Field
                    _buildTextField(
                      label: "Contact",
                      hintText: "Enter your contact",
                      initialValue: contact,
                      onChanged: (val) => contact = val,
                      keyboardType: TextInputType.phone,
                    ),

                    // ✅ City Field
                    _buildTextField(
                      label: "City",
                      hintText: "Enter your city",
                      initialValue: city,
                      onChanged: (val) => city = val,
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _saveProfile,
                        child: const Text(
                          "Save Profile",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ✅ Custom Text Field
  Widget _buildTextField({
    required String label,
    required String hintText,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: (val) => val!.isEmpty ? "This field is required" : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
