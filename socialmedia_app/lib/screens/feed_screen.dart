import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import '../widgets/add_post_sheet.dart';

class Post {
  final String category;
  final String content;
  Post({required this.category, required this.content});
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedFilter = "All Items";

  final List<Post> _allPosts = [
    Post(category: "🛠️ Tools", content: "Lending my drill for the weekend!"),
    Post(category: "🌿 Garden", content: "Fresh tomatoes available at my porch."),
    Post(category: "☕ Meetups", content: "Coffee at the park tomorrow?"),
    Post(category: "🆘 Help", content: "Lost dog found near the oak tree."),
    Post(category: "🛠️ Tools", content: "Need a lawnmower? I have one."),
    Post(category: "🌿 Garden", content: "Free sunflower seeds!"),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Post> filteredPosts = _selectedFilter == "All Items"
        ? _allPosts
        : _allPosts.where((post) => post.category == _selectedFilter).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Greenwood Hills",
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.white.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index < filteredPosts.length) {
                    final post = filteredPosts[index];
                    return PostCard(post: post);
                  }
                  return null;
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
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
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
