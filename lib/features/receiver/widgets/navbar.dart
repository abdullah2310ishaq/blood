import 'package:flutter/material.dart';

class ReceiverNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ReceiverNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: "Requests",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Find Donors",
        ),
      ],
    );
  }
}
