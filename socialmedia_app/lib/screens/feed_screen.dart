import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import '../widgets/add_post_sheet.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedFilter = "All Items";
  final PostService _postService = PostService();

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

  @override
  Widget build(BuildContext context) {
    final List<Post> allPosts = _postService.allPosts;
    
    // Filter logic
    final List<Post> filteredPosts = _selectedFilter == "All Items"
        ? allPosts
        : allPosts.where((post) => post.category == _selectedFilter).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Keeping the app bar structure consistent
          SliverAppBar(
            floating: true,
            title: const Text("Neighbors Porch", style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),

          // Filter Chips Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip("All Items"),
                    _buildFilterChip("🛠️ Tools"),
                    _buildFilterChip("🌿 Garden"),
                    _buildFilterChip("☕ Meetups"),
                    _buildFilterChip("🆘 Help"),
                  ],
                ),
              ),
            ),
          ),

          // THE FEED LIST
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return PostCard(post: filteredPosts[index]);
                },
                childCount: filteredPosts.length,
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00695C),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text("Share Something", style: TextStyle(color: Colors.white)),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddPostSheet(
              onPostAdded: (newPost) {
                _postService.addPost(newPost);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00695C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00695C) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
