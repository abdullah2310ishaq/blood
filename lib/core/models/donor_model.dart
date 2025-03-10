import 'package:cloud_firestore/cloud_firestore.dart';

class DonorModel {
  String uid;
  String bloodGroup;
  bool isActive;
  String city;

  DonorModel({
    required this.uid,
    required this.bloodGroup,
    required this.isActive,
    required this.city,
  });

  // Convert Firebase Document to DonorModel
  factory DonorModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DonorModel(
      uid: doc.id,
      bloodGroup: data['bloodGroup'],
      isActive: data['isActive'],
      city: data['city'],
    );
  }

  // Convert DonorModel to Firebase Map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "bloodGroup": bloodGroup,
      "isActive": isActive,
      "city": city,
    };
  }
}
