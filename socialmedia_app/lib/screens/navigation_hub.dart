import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart'; // Ensure this exists

/// The main navigation hub of the app, containing the bottom navigation bar.
class NavigationHub extends StatefulWidget {
  const NavigationHub({super.key});

  @override
  State<NavigationHub> createState() => _NavigationHubState();
}

class _NavigationHubState extends State<NavigationHub> {
  int _selectedIndex = 0; // Currently selected tab index
  int _unreadNotifications = 0; // Counter for unread activity

  // List of primary screens for each tab
  final List<Widget> _screens = [
    const FeedScreen(),
    const ChatScreen(),
    const NotificationsScreen(), // Added Notifications tab
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  /// Listens to real-time updates in the notifications collection for the current user.
  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Listen for notifications specifically for the logged-in user
    FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          // In a real app, you'd track a 'read' boolean field. 
          // For this MVP, we show the count of recent notifications.
          _unreadNotifications = snapshot.docs.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                // Reset counter when clicking the notifications tab
                if (index == 2) _unreadNotifications = 0;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF00695C),
            unselectedItemColor: Colors.grey[400],
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Porch',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chats',
              ),
              // THE NEW NOTIFICATIONS TAB
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text(_unreadNotifications.toString()),
                  isLabelVisible: _unreadNotifications > 0,
                  child: const Icon(Icons.notifications_none),
                ),
                activeIcon: Badge(
                  label: Text(_unreadNotifications.toString()),
                  isLabelVisible: _unreadNotifications > 0,
                  child: const Icon(Icons.notifications),
                ),
                label: 'Activity',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
