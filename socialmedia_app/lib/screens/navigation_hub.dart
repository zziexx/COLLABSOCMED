import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class NavigationHub extends StatefulWidget {
  const NavigationHub({super.key});

  @override
  State<NavigationHub> createState() => _NavigationHubState();
}

class _NavigationHubState extends State<NavigationHub> {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isNotEqualTo: user.uid)
        .orderBy('userId')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      if (mounted && _selectedIndex != 0) {
        setState(() {
          _unreadNotifications = snapshot.docChanges
              .where((change) => change.type == DocumentChangeType.added)
              .length;
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
                if (index == 0) _unreadNotifications = 0;
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
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text(_unreadNotifications.toString()),
                  isLabelVisible: _unreadNotifications > 0,
                  child: const Icon(Icons.home_outlined),
                ),
                activeIcon: Badge(
                  label: Text(_unreadNotifications.toString()),
                  isLabelVisible: _unreadNotifications > 0,
                  child: const Icon(Icons.home),
                ),
                label: 'Porch',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chats',
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
