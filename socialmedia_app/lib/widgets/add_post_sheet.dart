import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kIsWeb check
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/feed_screen.dart';

class AddPostSheet extends StatefulWidget {
  final Function(Post) onPostAdded;

  const AddPostSheet({super.key, required this.onPostAdded});

  @override
  State<AddPostSheet> createState() => _AddPostSheetState();
}

class _AddPostSheetState extends State<AddPostSheet> {
  String _selectedCategory = "🛠️ Tools";
  final TextEditingController _textController = TextEditingController();

  // Changed from File? to String? to support Web and Mobile paths
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _categoryMap = {
    "Lend": "🛠️ Tools",
    "Swap": "🌿 Garden",
    "Meetup": "☕ Meetups",
    "Help": "🆘 Help",
  };

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        // Store the path as a string
        _imagePath = pickedFile.path;
      });
    }
  }

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

          // Updated Image Preview Section
          if (_imagePath != null)
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: kIsWeb
                        ? Image.network(_imagePath!, fit: BoxFit.cover)
                        : Image.file(File(_imagePath!), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: GestureDetector(
                    onTap: () => setState(() => _imagePath = null),
                    child: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 15,
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),

          TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "What are you sharing today?",
              filled: true,
              fillColor: Colors.grey[100],
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_a_photo, color: Color(0xFF00695C)),
                onPressed: _pickImage,
              ),
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
                // Allows posting if there is either text OR an image
                if (_textController.text.isNotEmpty || _imagePath != null) {
                  final newPost = Post(
                    category: _selectedCategory,
                    content: _textController.text.isEmpty ? "" : _textController.text,
                    imagePath: _imagePath,
                  );
                  widget.onPostAdded(newPost);
                  Navigator.pop(context);
                } else {
                  // Show a message if both are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please add some text or an image")),
                  );
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
                    width: 2),
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