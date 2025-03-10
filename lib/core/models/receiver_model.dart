import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiverModel {
  String uid;
  String hospitalName;
  String patientName;
  String bloodGroup;
  bool isEmergency;
  String city;

  ReceiverModel({
    required this.uid,
    required this.hospitalName,
    required this.patientName,
    required this.bloodGroup,
    required this.isEmergency,
    required this.city,
  });

  // Convert Firebase Document to ReceiverModel
  factory ReceiverModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReceiverModel(
      uid: doc.id,
      hospitalName: data['hospitalName'],
      patientName: data['patientName'],
      bloodGroup: data['bloodGroup'],
      isEmergency: data['isEmergency'],
      city: data['city'],
    );
  }

  // Convert ReceiverModel to Firebase Map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "hospitalName": hospitalName,
      "patientName": patientName,
      "bloodGroup": bloodGroup,
      "isEmergency": isEmergency,
      "city": city,
    };
  }
}
