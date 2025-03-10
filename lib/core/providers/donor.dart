import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonorProvider with ChangeNotifier {
  String name = "";
  String contact = "";
  String city = "";
  String bloodGroup = "A+";
  bool isAvailable = true;
  String profilePicUrl = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Load Donor Data from Firestore
  Future<void> loadDonorData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      name = doc.get('name') ?? "";
      contact = doc.get('contact') ?? "";
      city = doc.get('city') ?? "";
      bloodGroup = doc.get('bloodGroup') ?? "A+";
      isAvailable = doc.get('isAvailable') ?? true;
      profilePicUrl = doc.get('profilePic') ?? "";
      notifyListeners();
    }
  }

  // ✅ Update Donor Profile
  Future<void> updateDonorProfile({
    required String newName,
    required String newContact,
    required String newCity,
    required String newBloodGroup,
    required bool newAvailability,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      "name": newName,
      "contact": newContact,
      "city": newCity,
      "bloodGroup": newBloodGroup,
      "isAvailable": newAvailability,
    });

    name = newName;
    contact = newContact;
    city = newCity;
    bloodGroup = newBloodGroup;
    isAvailable = newAvailability;
    notifyListeners();
  }
}
