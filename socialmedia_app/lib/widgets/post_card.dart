import 'package:flutter/material.dart';
import '../screens/feed_screen.dart'; // Import to access the Post class

class PostCard extends StatelessWidget {
  final Post post; // This cannot be null

  // Ensure 'required' is here
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00695C).withOpacity(0.1),
                  child: Text(post.category.characters.first),
                ),
                const SizedBox(width: 12),
                Text(
                  post.category,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
