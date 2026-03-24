import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import '../widgets/add_post_sheet.dart';
import '../models/post.dart';
import '../services/post_service.dart';

/// The main landing screen that displays a real-time feed of community posts.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedFilter = "All Items"; // Track current category filter
  final PostService _postService = PostService(); // Service to interact with Firestore posts
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ""; // Current text search input
  bool _isSearching = false; // Toggle for search bar visibility

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Post>>(
        // Listen to real-time updates of all posts from Firestore
        stream: _postService.allPostsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final List<Post> allPosts = snapshot.data ?? [];
          
          // Apply category filter and search query to the list of posts
          final List<Post> filteredPosts = allPosts.where((post) {
            final matchesFilter = _selectedFilter == "All Items" || post.category == _selectedFilter;
            final matchesSearch = _searchQuery.isEmpty || 
                post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                post.category.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesFilter && matchesSearch;
          }).toList();

          return CustomScrollView(
            slivers: [
              // Dynamic AppBar with Search capability
              SliverAppBar(
                floating: true,
                pinned: true,
                title: _isSearching 
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "Search posts...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    )
                  : const Text("Neighbors Porch", style: TextStyle(fontWeight: FontWeight.bold)),
                actions: [
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search), 
                    onPressed: () {
                      setState(() {
                        if (_isSearching) {
                          _isSearching = false;
                          _searchController.clear();
                          _searchQuery = "";
                        } else {
                          _isSearching = true;
                        }
                      });
                    }
                  ),
                ],
              ),

              // Category Filter Chips
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

              // The actual feed list
              filteredPosts.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text("No matching items found.")),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.only(bottom: 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Render each post using the PostCard widget
                            return PostCard(post: filteredPosts[index]);
                          },
                          childCount: filteredPosts.length,
                        ),
                      ),
                    ),
            ],
          );
        }
      ),

      // Floating Button to open the "Share Something" bottom sheet
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
              onPostAdded: (newPost, imageFile) async {
                // Call service to save the new post to Firestore
                await _postService.addPost(newPost, imageFile: imageFile);
              },
            ),
          );
        },
      ),
    );
  }

  /// Builds a clickable filter chip for category selection.
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
