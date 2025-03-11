import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notifications.dart'; // If you created the model

class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  // Fetch notifications for a specific user (receiver or donor)
  Future<void> fetchNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection("notifications")
          .where("userId", isEqualTo: userId)
          .orderBy("timestamp", descending: true)
          .get();

      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromDoc(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching notifications: $e");
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notifId) async {
    await _firestore.collection("notifications").doc(notifId).update({
      "isRead": true,
    });
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        extraData: _notifications[index].extraData,
      );
    }
    notifyListeners();
  }

  // Create a new notification doc
  Future<void> createNotification(NotificationModel notif) async {
    await _firestore.collection("notifications").add(notif.toMap());
  }
}
