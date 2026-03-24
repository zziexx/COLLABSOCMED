import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';

class PostService extends ChangeNotifier {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Real-time stream of all posts
  Stream<List<Post>> get allPostsStream {
    final currentUserId = _auth.currentUser?.uid ?? '';
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromMap(doc.data(), doc.id, currentUserId);
      }).toList();
    });
  }

  // Real-time stream of the current user's posts
  Stream<List<Post>> get userPostsStream {
    final currentUserId = _auth.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return Stream.value([]);
    
    return _db
        .collection('posts')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromMap(doc.data(), doc.id, currentUserId);
      }).toList();
    });
  }

  Future<String?> _convertImageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint("Error converting image: $e");
      return null;
    }
  }

  Future<void> addPost(Post post, {XFile? imageFile}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    String? imageUrl = post.imagePath;
    if (imageFile != null) {
      imageUrl = await _convertImageToBase64(imageFile);
    }

    final postWithUser = post.copyWith(
      userId: user.uid,
      createdAt: DateTime.now(),
      imagePath: imageUrl,
    );

    // 1. Save the Post to Firestore
    await _db.collection('posts').add(postWithUser.toMap());

    // 2. Create a Notification for others to see (Don't await this to avoid UI lag)
    _db.collection('notifications').add({
      'title': 'New Neighborhood Share!',
      'body': '${user.displayName ?? "A neighbor"} shared a ${post.category}.',
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'new_post',
    }).catchError((e) => debugPrint("Notification failed: $e"));
  }

  Future<void> removePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }

  Future<void> toggleAvailability(String id, bool currentStatus) async {
    await _db.collection('posts').doc(id).update({
      'isAvailable': !currentStatus,
    });
  }
}
