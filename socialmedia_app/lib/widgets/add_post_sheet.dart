import 'package:flutter/material.dart';
import '../screens/feed_screen.dart';

class AddPostSheet extends StatefulWidget {
  final Function(Post) onPostAdded; // Add this callback

  const AddPostSheet({super.key, required this.onPostAdded});

  @override
  State<AddPostSheet> createState() => _AddPostSheetState();
}

class _AddPostSheetState extends State<AddPostSheet> {
  String _selectedCategory = "🛠️ Tools";
  final TextEditingController _textController = TextEditingController();

  // Mapping labels to emojis to match FeedScreen categories
  final Map<String, String> _categoryMap = {
    "Lend": "🛠️ Tools",
    "Swap": "🌿 Garden",
    "Meetup": "☕ Meetups",
    "Help": "🆘 Help",
  };

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Share with neighbors",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Category Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _categoryIcon("🛠️", "Lend"),
                _categoryIcon("🌿", "Swap"),
                _categoryIcon("☕", "Meetup"),
                _categoryIcon("🆘", "Help"),
              ],
            ),
          ),

          const SizedBox(height: 20),
          TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "What are you sharing today?",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  final newPost = Post(
                    category: _selectedCategory,
                    content: _textController.text,
                  );
                  widget.onPostAdded(newPost); // Send data back
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Post to Community"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryIcon(String emoji, String label) {
    String categoryName = _categoryMap[label] ?? label;
    bool isSelected = _selectedCategory == categoryName;

    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = categoryName;
          });
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF00695C) : Colors.teal[50],
                border: Border.all(
                    color: isSelected ? Colors.teal[700]! : Colors.transparent,
                    width: 2
                ),
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF00695C) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
