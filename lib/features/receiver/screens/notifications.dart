import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/providers/notification.dart';
// Or wherever your NotificationProvider lives

class ReceiverNotificationsScreen extends StatefulWidget {
  const ReceiverNotificationsScreen({super.key});

  @override
  _ReceiverNotificationsScreenState createState() =>
      _ReceiverNotificationsScreenState();
}

class _ReceiverNotificationsScreenState extends State<ReceiverNotificationsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await Provider.of<NotificationProvider>(context, listen: false)
        .fetchNotifications(user.uid);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifs = notificationProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifs.isEmpty
              ? const Center(child: Text("No notifications."))
              : ListView.builder(
                  itemCount: notifs.length,
                  itemBuilder: (ctx, index) {
                    final notif = notifs[index];
                    return ListTile(
                      title: Text(notif.title),
                      subtitle: Text(notif.message),
                      trailing: notif.isRead
                          ? null
                          : ElevatedButton(
                              onPressed: () {
                                notificationProvider.markAsRead(notif.id);
                              },
                              child: const Text("Mark Read"),
                            ),
                      onTap: () {
                        // Possibly go to a details page, e.g. using notif.extraData
                      },
                    );
                  },
                ),
    );
  }
}
