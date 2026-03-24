class Post {
  final String id;
  final String category;
  final String content;
  final String? imagePath;
  final bool isUserPost;
  final bool isAvailable;
  final String? userId;
  final DateTime? createdAt;
  final String? locationName; // Manual location name

  Post({
    required this.id,
    required this.category,
    required this.content,
    this.imagePath,
    this.isUserPost = false,
    this.isAvailable = true,
    this.userId,
    this.createdAt,
    this.locationName,
  });

  Post copyWith({
    String? id,
    String? category,
    String? content,
    String? imagePath,
    bool? isUserPost,
    bool? isAvailable,
    String? userId,
    DateTime? createdAt,
    String? locationName,
  }) {
    return Post(
      id: id ?? this.id,
      category: category ?? this.category,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      isUserPost: isUserPost ?? this.isUserPost,
      isAvailable: isAvailable ?? this.isAvailable,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      locationName: locationName ?? this.locationName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'content': content,
      'imagePath': imagePath,
      'userId': userId,
      'isAvailable': isAvailable,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'locationName': locationName,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map, String id, String currentUserId) {
    return Post(
      id: id,
      category: map['category'] ?? '',
      content: map['content'] ?? '',
      imagePath: map['imagePath'],
      userId: map['userId'],
      isAvailable: map['isAvailable'] ?? true,
      isUserPost: map['userId'] == currentUserId,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt']) 
          : null,
      locationName: map['locationName'],
    );
  }
}
