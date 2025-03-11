import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final ImagePicker _picker = ImagePicker(); // For picking gallery images

  // 🔹 Fields
  String uid = "";
  String profilePicUrl = ""; // Store the profile photo URL
  String name = "";
  String contact = "";
  String city = "";
  String bloodGroup = "A+";
  int age = 18;
  String gender = "Male";
  DateTime? lastDonationDate;
  bool isActive = true;
  String additionalNotes = "";

  bool isLoading = true;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 🔹 Load User Data from Firestore
  Future<void> _loadUserProfile() async {
    try {
      User? user = _authService.getCurrentUser();
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      uid = user.uid;

      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          profilePicUrl = doc.get('profilePic') ?? ""; // ✅ Load profile pic URL
          name = doc.get('name') ?? "";
          contact = doc.get('contact') ?? "";
          city = doc.get('city') ?? "";
          bloodGroup = doc.get('bloodGroup') ?? "A+";
          age = doc.get('age') ?? 18;
          gender = doc.get('gender') ?? "Male";
          lastDonationDate = doc.get('lastDonationDate') != null
              ? DateTime.parse(doc.get('lastDonationDate'))
              : null;
          isActive = doc.get('isActive') ?? true;
          additionalNotes = doc.get('additionalNotes') ?? "";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔹 Save Updated Profile Data
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _authService.getCurrentUser();
        if (user == null) return;

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            "uid": user.uid,
            "profilePic": profilePicUrl, // Ensure we save the current pic URL
            "name": name,
            "contact": contact,
            "city": city,
            "bloodGroup": bloodGroup,
            "age": age,
            "gender": gender,
            "lastDonationDate": lastDonationDate?.toIso8601String(),
            "isActive": isActive,
            "additionalNotes": additionalNotes,
          },
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile updated successfully!"),
            backgroundColor: primaryColor,
          ),
        );
      } catch (e) {
        print("Error saving profile data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔹 Show a Bottom Sheet with "Change Photo" or "Remove Photo"
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Change Photo"),
              onTap: () {
                Navigator.pop(ctx);
                _pickNewProfilePic();
              },
            ),
            if (profilePicUrl.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Remove Photo"),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeProfilePic();
                },
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 Pick a new image from the gallery and upload to Firebase
  Future<void> _pickNewProfilePic() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _pickedImage = File(pickedFile.path));

    // 🔹 Upload to Firebase Storage
    User? user = _authService.getCurrentUser();
    if (user == null) return;
    try {
      final filePath = "profile_pics/${user.uid}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      await storageRef.putFile(_pickedImage!);

      final downloadUrl = await storageRef.getDownloadURL();
      setState(() => profilePicUrl = downloadUrl);

      // 🔹 Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({"profilePic": downloadUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!")),
      );
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  // 🔹 Remove existing profile pic from Firestore (and optionally Storage)
  Future<void> _removeProfilePic() async {
    if (profilePicUrl.isEmpty) return;

    User? user = _authService.getCurrentUser();
    if (user == null) return;

    try {
      // OPTIONAL: Also remove from Firebase Storage
      // Only do this if you truly want to delete the file entirely.
      // If you want to keep the old file in storage, remove these lines.
      final storageRef = FirebaseStorage.instance.refFromURL(profilePicUrl);
      await storageRef.delete();

      // Set Firestore "profilePic" to empty
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({"profilePic": ""});

      setState(() => profilePicUrl = "");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture removed.")),
      );
    } catch (e) {
      print("Error removing profile picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Soft creamy white

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Profile Picture + Tap to Change
                    Center(
                      child: GestureDetector(
                        onTap: _showImageOptions,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: profilePicUrl.isNotEmpty
                              ? NetworkImage(profilePicUrl) as ImageProvider
                              : null,
                          child: profilePicUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Name Field
                    const Text("Name",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      initialValue: name,
                      decoration: _inputDecoration(hintText: "Enter your name"),
                      onChanged: (val) => name = val,
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Contact Field
                    const Text("Contact",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      initialValue: contact,
                      decoration:
                          _inputDecoration(hintText: "Enter your contact"),
                      keyboardType: TextInputType.phone,
                      onChanged: (val) => contact = val,
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Age Field
                    const Text("Age",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      initialValue: age.toString(),
                      decoration: _inputDecoration(hintText: "Enter your age"),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => age = int.tryParse(val) ?? 18,
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Gender Dropdown
                    const Text("Gender",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: gender,
                      items: ["Male", "Female"]
                          .map((gen) => DropdownMenuItem(
                                value: gen,
                                child: Text(gen),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => gender = value!),
                      decoration: _inputDecoration(),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 City Field
                    const Text("City",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      initialValue: city,
                      decoration: _inputDecoration(hintText: "Enter your city"),
                      onChanged: (val) => city = val,
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Blood Group Dropdown
                    const Text("Blood Group",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: bloodGroup,
                      items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                          .map((bg) => DropdownMenuItem(
                                value: bg,
                                child: Text(bg),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => bloodGroup = value!),
                      decoration: _inputDecoration(),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Availability Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Active Donor?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: isActive,
                          activeColor: primaryColor,
                          onChanged: (value) =>
                              setState(() => isActive = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Last Donation Date Picker
                    const Text("Last Donation Date",
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                        decoration: _inputDecoration(
                          hintText: lastDonationDate == null
                              ? "Select Date"
                              : "${lastDonationDate!.day}/${lastDonationDate!.month}/${lastDonationDate!.year}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Additional Notes
                    const Text("Additional Notes",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      initialValue: additionalNotes,
                      maxLines: 3,
                      decoration:
                          _inputDecoration(hintText: "Any extra info..."),
                      onChanged: (val) => additionalNotes = val,
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Save Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Save Profile",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // 🔹 Reusable Input Decoration
  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }
}
