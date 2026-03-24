import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // POSTER INFO HEADER
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: post.userId),
                    ),
                  );
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.teal[50],
                        backgroundImage: photoData != null ? _buildAvatarImage(photoData) : null,
                        child: photoData == null ? const Icon(Icons.person, size: 20, color: Color(0xFF00695C)) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Row(
                              children: [
                                Text(post.category, style: const TextStyle(color: Color(0xFF00695C), fontSize: 12)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: post.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          post.isAvailable ? "Available" : "Not Available",
                          style: TextStyle(
                            color: post.isAvailable ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      post.content,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                if (post.imagePath != null && post.imagePath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildPostImage(post.imagePath!),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IndividualChatScreen(
                              name: name,
                              sharedPost: post,
                            ),
                          ),
                        );
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

  ImageProvider? _buildAvatarImage(String data) {
    if (data.startsWith('http')) {
      return NetworkImage(data);
    } else {
      try {
        return MemoryImage(base64Decode(data));
      } catch (e) {
        return null;
      }
    }
  }

  Widget _buildPostImage(String path) {
    if (path.length > 500) {
      return Image.memory(
        base64Decode(path),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );
    } else if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    } else {
      return Image.file(
        File(path),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }
  }
}
