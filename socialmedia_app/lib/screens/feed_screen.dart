import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import '../widgets/add_post_sheet.dart';

class Post {
  final String category;
  final String content;
  final String? imagePath; // <--- Make sure this line exists

  Post({
    required this.category,
    required this.content,
    this.imagePath, // <--- Make sure this is in the constructor
  });
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedFilter = "All Items";

  // Mock data - existing posts don't have images (imagePath: null)
  final List<Post> _allPosts = [
    Post(category: "🛠️ Tools", content: "Lending my drill for the weekend!"),
    Post(category: "🌿 Garden", content: "Fresh tomatoes available at my porch."),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final List<Post> filteredPosts = _selectedFilter == "All Items"
        ? _allPosts
        : _allPosts.where((post) => post.category == _selectedFilter).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ... (Keep your SliverAppBar code here)

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

          // 2. THE FEED LIST
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // Passes the Post (including imagePath) to the PostCard
                  return PostCard(post: filteredPosts[index]);
                },
                childCount: filteredPosts.length,
              ),
            ),
          ),
        ],
      ),

      // 3. TRIGGERING THE UPLOAD SHEET
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
                // This updates the feed list with the new post + image
                setState(() {
                  _allPosts.insert(0, newPost);
                });
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