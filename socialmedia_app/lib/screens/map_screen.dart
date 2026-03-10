import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a Stack so the Search Bar stays fixed while the map moves
      body: Stack(
        children: [
          // 1. The Zoomable/Pannable Map Area
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(500), // Space to pan around
            minScale: 0.5,
            maxScale: 2.5,
            // Set the initial view to the center of our "world"
            child: Stack(
              children: [
                // The "Ground" of our map
                Container(
                  width: 2000,
                  height: 2000,
                  color: Colors.teal[50],
                ),

                // Static Pins positioned in our 2000x2000 world
                const MapPin(top: 800, left: 900, emoji: "🛠️", label: "Drill"),
                const MapPin(top: 950, left: 1100, emoji: "🌿", label: "Seeds"),
                const MapPin(top: 1100, left: 850, emoji: "☕", label: "Coffee"),
                const MapPin(top: 850, left: 1200, emoji: "🆘", label: "Help"),
              ],
            ),
          ),

          // 2. The Fixed UI (Search Bar) - Stays on top while map moves
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Text("Search for tools, plants...", style: TextStyle(color: Colors.grey)),
                  Spacer(),
                  Icon(Icons.tune, color: Color(0xFF00695C)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. The MapPin Widget Definition (Fixes the "Undefined" error)
class MapPin extends StatelessWidget {
  final double top;
  final double left;
  final String emoji;
  final String label;

  const MapPin({
    super.key,
    required this.top,
    required this.left,
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}