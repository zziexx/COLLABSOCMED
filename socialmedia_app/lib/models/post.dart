class Post {
  final String id;
  final String category;
  final String content;
  final String? imagePath;
  final bool isUserPost;
  final bool isAvailable; // New field for availability status

  Post({
    required this.id,
    required this.category,
    required this.content,
    this.imagePath,
    this.isUserPost = false,
    this.isAvailable = true, // Default to true
  });

  Post copyWith({
    String? id,
    String? category,
    String? content,
    String? imagePath,
    bool? isUserPost,
    bool? isAvailable,
  }) {
    return Post(
      id: id ?? this.id,
      category: category ?? this.category,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      isUserPost: isUserPost ?? this.isUserPost,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
