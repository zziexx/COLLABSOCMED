import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kIsWeb check
import 'package:flutter/material.dart';
import '../screens/feed_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Category Header (Restored)
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF00695C).withOpacity(0.1),
                  child: Text(
                    post.category.isNotEmpty ? post.category.characters.first : "?",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  post.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Text Content
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  post.content,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

            // 3. Image Section (Safe for Web and Mobile)
            if (post.imagePath != null && post.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(
                  post.imagePath!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(post.imagePath!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink(); // Hide if file not found
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}