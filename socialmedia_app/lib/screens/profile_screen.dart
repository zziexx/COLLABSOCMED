import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _postService.addListener(_onPostsChanged);
  }

  @override
  void dispose() {
    _postService.removeListener(_onPostsChanged);
    super.dispose();
  }

  void _onPostsChanged() {
    setState(() {});
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text("Edit Profile"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text("Notifications"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text("Privacy & Safety"),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Log Out", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                        (route) => false,
                  );
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
    final List<Post> userPosts = _postService.userPosts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Porch"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal[50],
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
              onBackgroundImageError: (exception, stackTrace) {},
              child: const Icon(Icons.person, size: 50, color: Color(0xFF00695C)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Alex Rivera",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Greenwood Hills • Member since 2024"),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(userPosts.length.toString(), "Items Lent"),
                _buildStat("48", "Help Points"),
                _buildStat("5.0", "Rating"),
              ],
            ),

            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Divider(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Your Shared Items",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    }, 
                    child: Text(_isEditing ? "Done" : "Edit All")
                  ),
                ],
              ),
            ),

            if (userPosts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Text("You haven't shared any items yet.", style: TextStyle(color: Colors.grey)),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.75,
                ),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  final post = userPosts[index];
                  return Stack(
                    children: [
                      _buildItemCard(post),
                      if (_isEditing)
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: () {
                              _postService.removePost(post.id);
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 15,
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
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildItemCard(Post post) {
    final String title = post.content.isEmpty ? post.category : post.content;
    final String imagePath = post.imagePath ?? "";
    
    Widget imageWidget;
    
    if (imagePath.isEmpty) {
      imageWidget = Container(
        color: Colors.teal[50],
        child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF00695C))),
      );
    } else if (kIsWeb || imagePath.startsWith('http') || imagePath.startsWith('blob:')) {
      imageWidget = Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.teal[50],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.teal[50],
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF00695C)),
            ),
          );
        },
      );
    } else {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.teal[50],
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF00695C)),
            ),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: imageWidget,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _postService.toggleAvailability(post.id),
                  child: Container(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
