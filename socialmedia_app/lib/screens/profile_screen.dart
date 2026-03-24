import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/onboarding_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/chat_screen.dart';
import '../models/post.dart';
import '../services/post_service.dart';

/// Screen displaying user profile information and their shared posts.
class ProfileScreen extends StatefulWidget {
  final String? userId; // Optional: ID of the user whose profile is being viewed
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _isEditing = false; // Toggle for post deletion mode
  bool _isUpdatingPhoto = false; // Loading state for photo upload

  // Determine whose profile is being viewed (defaults to current user)
  String get _effectiveUserId => widget.userId ?? _currentUserId ?? "";
  bool get _isOwnProfile => _effectiveUserId == _currentUserId;

  /// Opens gallery to pick and upload a new profile picture.
  Future<void> _updateProfilePicture() async {
    if (!_isOwnProfile) return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30, // Compress to keep Firestore document size small
      maxWidth: 300,
    );

    if (image == null) return;

    setState(() => _isUpdatingPhoto = true);

    try {
      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      // Save the base64 image string directly to the user's document
      await FirebaseFirestore.instance.collection('users').doc(_effectiveUserId).update({
        'photoUrl': base64Image,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update photo: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPhoto = false);
    }
  }

  /// Opens a dialog to change the user's display name.
  void _showEditProfileDialog(String currentName) {
    if (!_isOwnProfile) return;
    
    final TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Display Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final newName = nameController.text.trim();
                final user = FirebaseAuth.instance.currentUser;
                await user?.updateDisplayName(newName);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_effectiveUserId)
                    .update({'name': newName});
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// Displays a menu with settings like edit name, change photo, or logout.
  void _showSettingsMenu(BuildContext context, String currentName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_isOwnProfile) ...[
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text("Edit Profile Name"),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showEditProfileDialog(currentName);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text("Change Profile Picture"),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _updateProfilePicture();
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text("Notifications"),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Log Out", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pop(bottomSheetContext);
                    Navigator.pushAndRemoveUntil(
                      context, MaterialPageRoute(builder: (context) => const OnboardingScreen()), (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // Listen to profile data for the user being viewed
      stream: FirebaseFirestore.instance.collection('users').doc(_effectiveUserId).snapshots(),
      builder: (context, userSnapshot) {
        String displayName = "Neighbor";
        String memberSince = "2024";
        String? photoData;

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          displayName = data['name'] ?? displayName;
          memberSince = data['memberSince'] ?? memberSince;
          photoData = data['photoUrl'];
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_isOwnProfile ? "Your Porch" : "$displayName's Porch"),
            actions: [
              if (_isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _showSettingsMenu(context, displayName),
                ),
            ],
          ),
          body: StreamBuilder<List<Post>>(
            // Listen to real-time updates for posts shared by this specific user
            stream: _isOwnProfile 
                ? _postService.userPostsStream 
                : FirebaseFirestore.instance
                    .collection('posts')
                    .where('userId', isEqualTo: _effectiveUserId)
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => Post.fromMap(doc.data(), doc.id, _currentUserId ?? ""))
                        .toList()),
            builder: (context, postSnapshot) {
              final List<Post> userPosts = postSnapshot.data ?? [];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Image with Edit button
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal[50],
                          backgroundImage: photoData != null ? _buildProfileImage(photoData) : null,
                          child: _isUpdatingPhoto 
                            ? const CircularProgressIndicator(color: Color(0xFF00695C))
                            : (photoData == null ? const Icon(Icons.person, size: 50, color: Color(0xFF00695C)) : null),
                        ),
                        if (_isOwnProfile)
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: _isUpdatingPhoto ? null : _updateProfilePicture,
                              child: const CircleAvatar(
                                radius: 18, backgroundColor: Color(0xFF00695C),
                                child: Icon(Icons.edit, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("Greenwood Hills • Member since $memberSince"),
                    
                    // Message button when viewing someone else's profile
                    if (!_isOwnProfile) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IndividualChatScreen(
                                name: displayName,
                                sharedPost: Post(id: "", category: "General Chat", content: "", userId: _effectiveUserId),
                                otherUserId: _effectiveUserId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text("Message Neighbor"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00695C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    // Display count of items shared
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(userPosts.length.toString(), "Items Shared"),
                      ],
                    ),

                    const Padding(padding: EdgeInsets.all(20.0), child: Divider()),

                    // List of posts shared by this user
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_isOwnProfile ? "Your Shared Items" : "$displayName's Shared Items",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (_isOwnProfile && userPosts.isNotEmpty)
                            TextButton(
                              onPressed: () => setState(() => _isEditing = !_isEditing),
                              child: Text(_isEditing ? "Done" : "Edit All"),
                            ),
                        ],
                      ),
                    ),

                    if (postSnapshot.connectionState == ConnectionState.waiting)
                      const Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator())
                    else if (userPosts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(_isOwnProfile ? "You haven't shared any items yet." : "No shared items yet.", style: const TextStyle(color: Colors.grey)),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.75,
                        ),
                        itemCount: userPosts.length,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];
                          return Stack(
                            children: [
                              _buildItemCard(post),
                              // Delete button shown in edit mode
                              if (_isEditing && _isOwnProfile)
                                Positioned(
                                  right: 5, top: 5,
                                  child: GestureDetector(
                                    onTap: () => _postService.removePost(post.id),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.red, radius: 15,
                                      child: Icon(Icons.remove, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              );
            }
          ),
        );
      },
    );
  }

  /// Helper to build an ImageProvider from base64 or URL profile data.
  ImageProvider _buildProfileImage(String data) {
    if (data.startsWith('http')) return NetworkImage(data);
    try {
      return MemoryImage(base64Decode(data));
    } catch (e) {
      return const NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d');
    }
  }

  /// Helper for building individual stat counters (e.g., "Items Shared").
  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  /// Builds an individual item card for the profile grid.
  Widget _buildItemCard(Post post) {
    final String title = post.content.isEmpty ? post.category : post.content;
    final String imagePath = post.imagePath ?? "";
    Widget imageWidget;

    if (imagePath.isEmpty) {
      imageWidget = Container(color: Colors.teal[50], child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF00695C))));
    } else if (imagePath.length > 500) {
      imageWidget = Image.memory(base64Decode(imagePath), fit: BoxFit.cover, width: double.infinity);
    } else {
      imageWidget = Image.network(imagePath, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,__,___) => Container(color: Colors.grey[200]));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: imageWidget)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                // Toggle availability badge
                GestureDetector(
                  onTap: _isOwnProfile ? () => _postService.toggleAvailability(post.id, post.isAvailable) : null,
                  child: Container(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
