import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';

/// Widget that displays an individual post card in the community feed.
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    final isMeetup = post.category.toLowerCase().contains("meetup") || post.category.contains("☕");
    final isLend = post.category.toLowerCase().contains("lend") || post.category.contains("🛠️") || post.category.contains("Tools");
    final isSOS = post.category.toLowerCase().contains("help") || post.category.contains("🆘");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isSOS ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
      ),
      elevation: isSOS ? 4 : 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Poster Info
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(post.userId).snapshots(),
            builder: (context, snapshot) {
              String name = "Neighbor";
              String? photoData;

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                name = data['name'] ?? name;
                photoData = data['photoUrl'];
              }

              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: post.userId)));
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isSOS ? Colors.red[50] : Colors.teal[50],
                        backgroundImage: photoData != null ? _buildAvatarImage(photoData) : null,
                        child: photoData == null ? Icon(Icons.person, size: 20, color: isSOS ? Colors.red : const Color(0xFF00695C)) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Row(
                              children: [
                                Text(post.category, 
                                  style: TextStyle(color: isSOS ? Colors.red : const Color(0xFF00695C), fontSize: 12, fontWeight: isSOS ? FontWeight.bold : FontWeight.normal)
                                ),
                                if (post.locationName != null && post.locationName!.isNotEmpty) ...[
                                  const Text(" • ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                  Text(post.locationName!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!isSOS) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: post.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          post.isAvailable ? "Available" : "Not Available",
                          style: TextStyle(color: post.isAvailable ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isSOS) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        child: const Text("URGENT", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // CONTENT: Text & Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(post.content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  ),
                if (post.imagePath != null && post.imagePath!.isNotEmpty)
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildPostImage(post.imagePath!)),
                
                if (isMeetup) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${post.attendees.length} neighbors attending", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
                
                if (isLend && post.bookedDates.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text("Booked Dates:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Wrap(
                    spacing: 8,
                    children: post.bookedDates.map((date) => Chip(
                      label: Text("${date.month}/${date.day}", style: const TextStyle(fontSize: 11)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          const Divider(height: 1, indent: 16, endIndent: 16),
          
          // ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ONLY SHOW JOIN IF AVAILABLE
                if (isMeetup && post.isAvailable)
                  TextButton.icon(
                    onPressed: () => _toggleRSVP(context, currentUserId),
                    icon: Icon(post.attendees.contains(currentUserId) ? Icons.check_circle : Icons.add_circle_outline, size: 20, color: const Color(0xFF00695C)),
                    label: Text(post.attendees.contains(currentUserId) ? "Going" : "Join Meetup", style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold)),
                  ),
                
                // ONLY SHOW BOOK DATE IF AVAILABLE
                if (isLend && !post.isUserPost && post.isAvailable)
                  TextButton.icon(
                    onPressed: () => _selectBookingDate(context),
                    icon: const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF00695C)),
                    label: const Text("Book Date", style: TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold)),
                  ),

                if (!post.isUserPost)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(post.userId).snapshots(),
                    builder: (context, snapshot) {
                      String name = "Neighbor";
                      if (snapshot.hasData && snapshot.data!.exists) {
                        name = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? name;
                      }
                      return TextButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualChatScreen(name: name, sharedPost: post, otherUserId: post.userId)));
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF00695C)),
                        label: const Text("Inquire", style: TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold)),
                      );
                    }
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRSVP(BuildContext context, String? userId) async {
    if (userId == null) return;
    try {
      final List<String> newAttendees = List.from(post.attendees);
      if (newAttendees.contains(userId)) {
        newAttendees.remove(userId);
      } else {
        newAttendees.add(userId);
      }
      await FirebaseFirestore.instance.collection('posts').doc(post.id).update({'attendees': newAttendees});
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Action failed.")));
    }
  }

  void _selectBookingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      try {
        final List<DateTime> newDates = List.from(post.bookedDates);
        if (!newDates.any((d) => d.year == picked.year && d.month == picked.month && d.day == picked.day)) {
          newDates.add(picked);
          await FirebaseFirestore.instance.collection('posts').doc(post.id).update({'bookedDates': newDates.map((d) => d.millisecondsSinceEpoch).toList()});
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Date booked!")));
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Action failed.")));
      }
    }
  }

  ImageProvider? _buildAvatarImage(String data) {
    if (data.startsWith('http')) return NetworkImage(data);
    try { return MemoryImage(base64Decode(data)); } catch (e) { return null; }
  }

  Widget _buildPostImage(String path) {
    if (path.length > 500) {
      return Image.memory(base64Decode(path), width: double.infinity, height: 250, fit: BoxFit.cover);
    } else {
      return Image.network(path, width: double.infinity, height: 250, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink());
    }
  }
}
