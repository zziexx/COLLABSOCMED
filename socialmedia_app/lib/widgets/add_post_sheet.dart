import 'package:flutter/material.dart';

class AddPostSheet extends StatefulWidget {
  const AddPostSheet({super.key});

  @override
  State<AddPostSheet> createState() => _AddPostSheetState();
}

class _AddPostSheetState extends State<AddPostSheet> {
  // Track the selected category
  String _selectedCategory = "Lend";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery
            .of(context)
            .viewInsets
            .bottom + 20,
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
                // Here you can use _selectedCategory to save your post
                print("Posting to category: $_selectedCategory");
                Navigator.pop(context);
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
    bool isSelected = _selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
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