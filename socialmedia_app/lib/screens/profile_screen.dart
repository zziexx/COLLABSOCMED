import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // 1. Helper function to show the settings menu
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Menu only takes as much space as needed
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text("Edit Profile"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text("Notifications"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text("Privacy & Safety"),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Log Out", style: TextStyle(color: Colors.red)),
                onTap: () {
                  // 1. Close the Bottom Sheet first
                  Navigator.pop(context);

                  // 2. Navigate to Onboarding and clear the navigation history
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                        (route) => false, // This line removes all previous screens
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sharedItems = [
      {
        "title": "Mountain Bike",
        "image": "https://tse1.mm.bing.net/th/id/OIP._0S85LmNCCw2j_oGSE5uqgHaE8?rs=1&pid=ImgDetMain&o=7&rm=3"
      },
      {
        "title": "Projector",
        "image": "https://cdn.shopify.com/s/files/1/1703/3025/files/UHD663_600x600.webp?v=1690418464"
      },
      {
        "title": "Camping Tent",
        "image": "https://www.thecrazyoutdoormama.com/wp-content/uploads/2023/05/camping-setup-ideas-morris-m.jpg"
      },
      {
        "title": "Pressure Washer",
        "image": "https://m.media-amazon.com/images/I/719hY-wvVqL._AC_SL1500_.jpg"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Porch"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsMenu(context), // 2. Connected the function here
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal[50],
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
              onBackgroundImageError: (exception, stackTrace) {
                // Background image error handling
              },
              child: const Icon(Icons.person, size: 50, color: Color(0xFF00695C)), // Fallback icon if image fails
            ),
            const SizedBox(height: 16),
            const Text(
              "Alex Rivera",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Greenwood Hills • Member since 2024"),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("12", "Items Lent"),
                _buildStat("48", "Help Points"),
                _buildStat("5.0", "Rating"),
              ],
            ),

            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Divider(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Your Shared Items",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text("Edit All")),
                ],
              ),
            ),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              itemCount: sharedItems.length,
              itemBuilder: (context, index) {
                // Safety check: ensure the data exists before passing to widget
                final item = sharedItems[index];
                return _buildItemCard(
                    item["title"] ?? "Unknown Item", // Fallback if null
                    item["image"] ?? ""             // Fallback if null
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ... (Stats and ItemCard helper methods remain the same)
  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildItemCard(String title, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.teal[50],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.teal[50],
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF00695C)),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text("Available", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
