import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? extraData;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.extraData,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data["userId"],
      title: data["title"],
      message: data["message"],
      timestamp: (data["timestamp"] as Timestamp).toDate(),
      isRead: data["isRead"] ?? false,
      extraData: data["extraData"] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "title": title,
      "message": message,
      "timestamp": timestamp,
      "isRead": isRead,
      "extraData": extraData,
    };
  }
}
