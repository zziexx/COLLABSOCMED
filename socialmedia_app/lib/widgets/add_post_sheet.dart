import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';

class AddPostSheet extends StatefulWidget {
  final Future<void> Function(Post, XFile?) onPostAdded;

  const AddPostSheet({super.key, required this.onPostAdded});

  @override
  State<AddPostSheet> createState() => _AddPostSheetState();
}

class _AddPostSheetState extends State<AddPostSheet> {
  String _selectedCategory = "🛠️ Tools";
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  XFile? _imageFile;
  bool _isUploading = false;
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
      imageQuality: 50,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _locationController.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Share with neighbors",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
            if (_imageFile != null)
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
                      child: _buildPreviewImage(),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: GestureDetector(
                      onTap: () => setState(() => _imageFile = null),
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
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: "Where is this located? (e.g. Greenwood Hills)",
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF00695C)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isUploading ? null : () async {
                  if (_textController.text.isNotEmpty || _imageFile != null) {
                    setState(() => _isUploading = true);
                    
                    try {
                      final newPost = Post(
                        id: "", 
                        category: _selectedCategory,
                        content: _textController.text,
                        isUserPost: true,
                        locationName: _locationController.text.trim(),
                      );
                      
                      await widget.onPostAdded(newPost, _imageFile);
                      
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isUploading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to post: $e")),
                        );
                      }
                    }
                  } else {
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
                child: _isUploading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Post to Community"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage() {
    if (_imageFile == null) return const SizedBox.shrink();
    if (kIsWeb) return Image.network(_imageFile!.path, fit: BoxFit.cover);
    return Image.file(File(_imageFile!.path), fit: BoxFit.cover);
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
