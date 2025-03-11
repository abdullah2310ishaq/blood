import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String receiverId;
  final String? donorId;
  final String bloodGroup;
  final int units;
  final String location;
  final String status;
  final DateTime? timestamp;

  RequestModel({
    required this.id,
    required this.receiverId,
    this.donorId,
    required this.bloodGroup,
    required this.units,
    required this.location,
    required this.status,
    this.timestamp,
  });

  // Create a RequestModel from a Firestore doc
  factory RequestModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      receiverId: data["receiverId"],
      donorId: data["donorId"],
      bloodGroup: data["bloodGroup"],
      units: data["units"],
      location: data["location"],
      status: data["status"],
      timestamp: data["timestamp"] != null
          ? (data["timestamp"] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Map for writing to Firestore
  Map<String, dynamic> toMap() {
    return {
      "receiverId": receiverId,
      "donorId": donorId,
      "bloodGroup": bloodGroup,
      "units": units,
      "location": location,
      "status": status,
      "timestamp": timestamp,
    };
  }
}
