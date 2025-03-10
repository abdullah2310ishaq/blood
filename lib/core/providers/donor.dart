import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonorProvider with ChangeNotifier {
  String name = "";
  String contact = "";
  String city = "";
  String bloodGroup = "A+";
  int age = 18; // Default age
  String gender = "Male"; // Default gender
  DateTime? lastDonationDate;
  bool isAvailable = true;
  String profilePicUrl = "";
  String additionalNotes = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Load Donor Data from Firestore
  Future<void> loadDonorData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      name = doc.get('name') ?? "";
      contact = doc.get('contact') ?? "";
      city = doc.get('city') ?? "";
      bloodGroup = doc.get('bloodGroup') ?? "A+";
      age = doc.get('age') ?? 18;
      gender = doc.get('gender') ?? "Male";
      lastDonationDate = doc.get('lastDonationDate') != null
          ? DateTime.parse(doc.get('lastDonationDate'))
          : null;
      isAvailable = doc.get('isAvailable') ?? true;
      profilePicUrl = doc.get('profilePic') ?? "";
      additionalNotes = doc.get('additionalNotes') ?? "";
      notifyListeners();
    }
  }

  // ✅ Update Donor Profile
  Future<void> updateDonorProfile({
    required String newName,
    required String newContact,
    required String newCity,
    required String newBloodGroup,
    required int newAge,
    required String newGender,
    DateTime? newLastDonationDate,
    required bool newAvailability,
    required String newAdditionalNotes,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      "name": newName,
      "contact": newContact,
      "city": newCity,
      "bloodGroup": newBloodGroup,
      "age": newAge,
      "gender": newGender,
      "lastDonationDate": newLastDonationDate?.toIso8601String(),
      "isAvailable": newAvailability,
      "additionalNotes": newAdditionalNotes,
    });

    name = newName;
    contact = newContact;
    city = newCity;
    bloodGroup = newBloodGroup;
    age = newAge;
    gender = newGender;
    lastDonationDate = newLastDonationDate;
    isAvailable = newAvailability;
    additionalNotes = newAdditionalNotes;
    notifyListeners();
  }
}
