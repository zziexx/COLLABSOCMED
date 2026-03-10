import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {"name": "Sarah M.", "msg": "The ladder is on the porch!", "time": "2m ago"},
      {"name": "James K.", "msg": "Thanks for the tomatoes!", "time": "1h ago"},
      {"name": "Garden Group", "msg": "Meeting at 5 PM today 🌿", "time": "3h ago"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Neighbors", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange[100],
              child: Text(chats[index]["name"]![0], style: const TextStyle(color: Colors.orange)),
            ),
            title: Text(chats[index]["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chats[index]["msg"]!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(chats[index]["time"]!, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            onTap: () {
              // Navigate to specific chat logic
            },
          );
        },
      ),
    );
  }
}