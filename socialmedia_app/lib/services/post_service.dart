import 'package:flutter/foundation.dart';
import '../models/post.dart';

class PostService extends ChangeNotifier {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final List<Post> _allPosts = [
    // Feed items from others
    Post(
      id: "feed_1",
      category: "🛠️ Tools",
      content: "Lending my drill for the weekend!",
      isUserPost: false,
    ),
    Post(
      id: "feed_2",
      category: "🌿 Garden",
      content: "Fresh tomatoes available at my porch.",
      isUserPost: false,
    ),
    
    // User's own items (appearing in Profile)
    Post(
      id: "user_1",
      category: "🛠️ Tools",
      content: "Mountain Bike",
      imagePath: "https://tse1.mm.bing.net/th/id/OIP._0S85LmNCCw2j_oGSE5uqgHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
      isUserPost: true,
    ),
    Post(
      id: "user_2",
      category: "🛠️ Tools",
      content: "Projector",
      imagePath: "https://cdn.shopify.com/s/files/1/1703/3025/files/UHD663_600x600.webp?v=1690418464",
      isUserPost: true,
    ),
    Post(
      id: "user_3",
      category: "🌿 Garden",
      content: "Camping Tent",
      imagePath: "https://www.thecrazyoutdoormama.com/wp-content/uploads/2023/05/camping-setup-ideas-morris-m.jpg",
      isUserPost: true,
    ),
    Post(
      id: "user_4",
      category: "🛠️ Tools",
      content: "Pressure Washer",
      imagePath: "https://m.media-amazon.com/images/I/719hY-wvVqL._AC_SL1500_.jpg",
      isUserPost: true,
    ),
  ];

  List<Post> get allPosts => List.unmodifiable(_allPosts);

  List<Post> get userPosts => _allPosts.where((post) => post.isUserPost).toList();

  void addPost(Post post) {
    _allPosts.insert(0, post);
    notifyListeners();
  }

  void removePost(String id) {
    _allPosts.removeWhere((post) => post.id == id);
    notifyListeners();
  }

  void toggleAvailability(String id) {
    final index = _allPosts.indexWhere((post) => post.id == id);
    if (index != -1) {
      _allPosts[index] = _allPosts[index].copyWith(
        isAvailable: !_allPosts[index].isAvailable,
      );
      notifyListeners();
    }
  }
}
