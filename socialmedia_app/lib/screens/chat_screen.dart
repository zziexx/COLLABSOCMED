import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String _geminiApiKey = 'AIzaSyAEY8EjEkKyKke85-KwPOzoGL-ziTP_UMk';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {"name": "Gemini Assistant", "msg": "I'm here to help!", "time": "Now", "avatar": "G"},
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
              backgroundColor: const Color(0x1A00695C),
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
  final List<Map<String, String>> _messages = []; 
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    // Initialize Gemini with the stable v1 model
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _geminiApiKey,
    );
    _chat = _model.startChat();
    
    // Initial greeting
    _messages.add({"role": "model", "text": "Hi! I'm ${widget.name}. How can I help you today?"});
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Send message to Gemini
      final response = await _chat.sendMessage(Content.text(text));

      if (mounted) {
        setState(() {
          _messages.add({"role": "model", "text": response.text ?? "I'm not sure how to respond to that."});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // If 1.5-flash fails, it might be a regional or version issue. 
        // Showing the error clearly to help debugging.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF00695C) : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 20),
                      ),
                    ),
                    child: Text(
                      msg["text"] ?? "", 
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87)
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Neighbor is thinking...", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
              onSubmitted: (_) => _sendMessage(),
              textCapitalization: TextCapitalization.sentences,
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
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
