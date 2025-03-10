import 'package:cloud_firestore/cloud_firestore.dart';

class DonorModel {
  String uid;
  String bloodGroup;
  int age;
  String gender;
  String city;
  DateTime? lastDonationDate;
  bool isActive;
  String? additionalNotes;

  DonorModel({
    required this.uid,
    required this.bloodGroup,
    required this.age,
    required this.gender,
    required this.city,
    this.lastDonationDate,
    required this.isActive,
    this.additionalNotes,
  });

  // Convert Firebase Document to DonorModel
  factory DonorModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DonorModel(
      uid: doc.id,
      bloodGroup: data['bloodGroup'],
      age: data['age'],
      gender: data['gender'],
      city: data['city'],
      lastDonationDate: data['lastDonationDate'] != null
          ? DateTime.parse(data['lastDonationDate'])
          : null,
      isActive: data['isActive'],
      additionalNotes: data['additionalNotes'],
    );
  }

  // Convert DonorModel to Firebase Map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "bloodGroup": bloodGroup,
      "age": age,
      "gender": gender,
      "city": city,
      "lastDonationDate": lastDonationDate?.toIso8601String(),
      "isActive": isActive,
      "additionalNotes": additionalNotes,
    };
  }
}
