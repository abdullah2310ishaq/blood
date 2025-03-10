import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String name;
  String email;
  String contact;
  String role; // "donor" or "receiver"
  String? profilePic;
  String city;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.contact,
    required this.role,
    this.profilePic,
    required this.city,
  });

  // Convert Firebase Document to UserModel
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'],
      email: data['email'],
      contact: data['contact'],
      role: data['role'],
      profilePic: data['profilePic'],
      city: data['city'],
    );
  }

  // Convert UserModel to Firebase Map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "contact": contact,
      "role": role,
      "profilePic": profilePic,
      "city": city,
    };
  }
}
