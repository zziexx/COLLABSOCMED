/// Model class representing a post in the community feed.
class Post {
  final String id; // Unique document ID from Firestore
  final String category; // Category (e.g., Tools, Meetup, SOS)
  final String content; // Text content of the post
  final String? imagePath; // Base64 or URL path to the post image
  final bool isUserPost; // Flag to identify if the current user created this post
  final bool isAvailable; // Availability status for lending/swapping
  final String? userId; // ID of the user who created the post
  final DateTime? createdAt; // Timestamp when the post was created
  final String? locationName; // Manual location description
  final List<String> attendees; // List of user IDs who RSVP'd (for Meetups)
  final List<DateTime> bookedDates; // List of specific dates booked (for Lending)

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
    this.attendees = const [],
    this.bookedDates = const [],
  });

  /// Creates a copy of the Post with updated fields.
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
    List<String>? attendees,
    List<DateTime>? bookedDates,
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
      attendees: attendees ?? this.attendees,
      bookedDates: bookedDates ?? this.bookedDates,
    );
  }

  /// Converts the Post object into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'content': content,
      'imagePath': imagePath,
      'userId': userId,
      'isAvailable': isAvailable,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'locationName': locationName,
      'attendees': attendees,
      'bookedDates': bookedDates.map((d) => d.millisecondsSinceEpoch).toList(),
    };
  }

  /// Factory method to create a Post object from a Firestore document map.
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
      attendees: List<String>.from(map['attendees'] ?? []),
      bookedDates: (map['bookedDates'] as List<dynamic>?)
              ?.map((d) => DateTime.fromMillisecondsSinceEpoch(d as int))
              .toList() ??
          [],
    );
  }
}
