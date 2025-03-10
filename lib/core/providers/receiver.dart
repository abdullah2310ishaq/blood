import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceiverProvider with ChangeNotifier {
  String uid = "";
  String name = "";
  String contact = "";
  String city = "";
  String profilePicUrl = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Load Receiver Data from Firestore
  Future<void> loadReceiverData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      uid = user.uid;
      name = doc.get('name') ?? "";
      contact = doc.get('contact') ?? "";
      city = doc.get('city') ?? "";
      profilePicUrl = doc.get('profilePic') ?? "";
      notifyListeners(); // Update UI
    }
  }

  // ✅ Update Receiver Profile
  Future<void> updateReceiverProfile({
    required String newName,
    required String newContact,
    required String newCity,
    required String newProfilePicUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      "name": newName,
      "contact": newContact,
      "city": newCity,
      "profilePic": newProfilePicUrl,
    });

    name = newName;
    contact = newContact;
    city = newCity;
    profilePicUrl = newProfilePicUrl;
    notifyListeners(); // Refresh UI
  }
}
