import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {"name": "Sarah M.", "msg": "The ladder is on the porch!", "time": "2m ago", "avatar": "S"},
      {"name": "James K.", "msg": "Thanks for the tomatoes!", "time": "1h ago", "avatar": "J"},
      {"name": "Garden Group", "msg": "Meeting at 5 PM today 🌿", "time": "3h ago", "avatar": "G"},
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
              backgroundColor: const Color(0xFF00695C).withOpacity(0.1),
              child: Text(chats[index]["avatar"]!, style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold)),
            ),
            title: Text(chats[index]["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chats[index]["msg"]!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(chats[index]["time"]!, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndividualChatScreen(name: chats[index]["name"]!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class IndividualChatScreen extends StatefulWidget {
  final String name;
  const IndividualChatScreen({super.key, required this.name});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final List<String> _messages = ["Hi! I'm interested in the item you posted."];
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00695C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_messages[index], style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF00695C),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    _messages.add(_controller.text);
                    _controller.clear();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
