import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapPinData? _selectedPin;

  final List<MapPinData> _pins = [
    MapPinData(id: "1", top: 800, left: 900, emoji: "🛠️", label: "Power Drill", owner: "Sarah M.", desc: "Available until Sunday!"),
    MapPinData(id: "2", top: 950, left: 1100, emoji: "🌿", label: "Tomato Seeds", owner: "James K.", desc: "Heirloom varieties."),
    MapPinData(id: "3", top: 1100, left: 850, emoji: "☕", label: "Garden Meetup", owner: "Greenwood Group", desc: "Weekly planning."),
    MapPinData(id: "4", top: 850, left: 1200, emoji: "🆘", label: "Need Help: Lifting", owner: "Mrs. Higgins", desc: "Moving some boxes."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(1000),
            minScale: 0.1,
            maxScale: 2.5,
            child: Stack(
              children: [
                Container(width: 3000, height: 3000, color: Colors.teal[50]),
                ..._pins.map((pin) => MapPinWidget(
                  data: pin,
                  isSelected: _selectedPin?.id == pin.id,
                  onTap: () => setState(() => _selectedPin = pin),
                )).toList(),
              ],
            ),
          ),

          // Search Bar
          Positioned(
            top: 60, left: 20, right: 20,
            child: _buildSearchBar(),
          ),

          // Selected Item Detail Card
          if (_selectedPin != null)
            Positioned(
              bottom: 100, left: 20, right: 20,
              child: _buildDetailCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Text("Search neighborhood...", style: TextStyle(color: Colors.grey)),
          Spacer(),
          Icon(Icons.tune, color: Color(0xFF00695C)),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.teal[50], child: Text(_selectedPin!.emoji)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedPin!.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Posted by ${_selectedPin!.owner}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedPin = null)),
              ],
            ),
            const Divider(),
            Text(_selectedPin!.desc),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logic to jump to chat would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Starting chat with ${_selectedPin!.owner}...")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Message Neighbor"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MapPinData {
  final String id, emoji, label, owner, desc;
  final double top, left;
  MapPinData({required this.id, required this.top, required this.left, required this.emoji, required this.label, required this.owner, required this.desc});
}

class MapPinWidget extends StatelessWidget {
  final MapPinData data;
  final bool isSelected;
  final VoidCallback onTap;

  const MapPinWidget({super.key, required this.data, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: data.top,
      left: data.left,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00695C) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(data.emoji, style: const TextStyle(fontSize: 20)),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF00695C), borderRadius: BorderRadius.circular(8)),
                child: Text(data.label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
