import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import 'chat_screen.dart';

class NavigationHub extends StatefulWidget {
  const NavigationHub({super.key});

  @override
  State<NavigationHub> createState() => _NavigationHubState();
}

class _NavigationHubState extends State<NavigationHub> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const MapScreen(),
    const ChatScreen(), // Added ChatScreen here
    const Scaffold(body: Center(child: Text("Notifications"))),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00695C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"), // Added Chat Icon
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: "Alerts"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
