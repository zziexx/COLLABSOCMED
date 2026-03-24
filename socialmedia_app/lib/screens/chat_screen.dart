import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/chat_service.dart';

/// Screen that displays the list of all active conversations for the user.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Neighbors", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the real-time stream of chats the user is participating in
        stream: chatService.getMyChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading chats: ${snapshot.error}"));
          }

          // Show a placeholder if no chats exist
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "No chats yet. Reach out to a neighbor by clicking 'Inquire' on their post or 'Message' on their profile!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final chatDoc = snapshot.data!.docs[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;
              
              // Identify the other participant in the chat
              final List<dynamic> participants = chatData['participants'] ?? [];
              final otherId = participants.firstWhere((id) => id != currentUid, orElse: () => "");
              
              final names = chatData['names'] as Map<String, dynamic>?;
              final String otherName = names?[otherId] ?? "Neighbor";
              final String lastMsg = chatData['lastMessage'] ?? "New conversation";

              // Fetch the other user's profile info (photo) in real-time
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(otherId).snapshots(),
                builder: (context, userSnap) {
                  String? photoData;
                  if (userSnap.hasData && userSnap.data!.exists) {
                    photoData = (userSnap.data!.data() as Map<String, dynamic>)['photoUrl'];
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00695C).withOpacity(0.1),
                      backgroundImage: photoData != null ? _buildAvatarImage(photoData) : null,
                      child: photoData == null 
                        ? Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : "?", 
                            style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold))
                        : null,
                    ),
                    title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      // Navigate to the specific conversation thread
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndividualChatScreen(
                            name: otherName,
                            chatId: chatDoc.id,
                            otherUserId: otherId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Helper to convert base64 or URL strings to an ImageProvider
  ImageProvider? _buildAvatarImage(String data) {
    if (data.startsWith('http')) return NetworkImage(data);
    try {
      return MemoryImage(base64Decode(data));
    } catch (e) {
      return null;
    }
  }
}

/// Screen for a specific 1-on-1 chat conversation.
class IndividualChatScreen extends StatefulWidget {
  final String name; // Name of the neighbor being messaged
  final String? chatId; // Existing chat ID, if any
  final String? otherUserId; // UID of the neighbor
  final Post? sharedPost; // Optional post that triggered the chat

  const IndividualChatScreen({super.key, required this.name, this.chatId, this.otherUserId, this.sharedPost});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  String? _chatId;
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId;
    // If we don't have a chat ID yet (starting a new chat), create it
    if (_chatId == null && (widget.sharedPost != null || widget.otherUserId != null)) {
      _initChatFromPost();
    }
  }

  /// Creates a new chat record in Firestore and sends an initial inquiry if applicable.
  Future<void> _initChatFromPost() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final String otherUserId = widget.otherUserId ?? widget.sharedPost?.userId ?? "";
      if (otherUserId.isEmpty) throw Exception("User ID is missing");

      // Get or create the chat document
      final newChatId = await _chatService.getOrCreateChat(
        otherUserId, 
        widget.name
      );
      
      if (mounted) {
        setState(() {
          _chatId = newChatId;
          _isInitializing = false;
        });

        // If this chat started from a specific post inquiry, send that post info as the first message
        if (widget.sharedPost != null && widget.sharedPost!.id.isNotEmpty) {
          await _chatService.sendMessage(
            newChatId, 
            "Inquiring about: ${widget.sharedPost!.content.isEmpty ? widget.sharedPost!.category : widget.sharedPost!.content}",
            extraData: {
              'post_id': widget.sharedPost!.id,
              'is_inquiry': true,
              'post_category': widget.sharedPost!.category,
              'post_content': widget.sharedPost!.content,
              'post_image': widget.sharedPost!.imagePath,
            }
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = "Could not start chat: $e";
        });
      }
    }
  }

  /// Sends a text message to the neighbor.
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _chatId == null) return;

    _controller.clear();
    await _chatService.sendMessage(_chatId!, text);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the neighbor's user data for the app bar profile picture
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.otherUserId ?? "").snapshots(),
      builder: (context, userSnap) {
        String? photoData;
        if (userSnap.hasData && userSnap.data!.exists) {
          photoData = (userSnap.data!.data() as Map<String, dynamic>)['photoUrl'];
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.teal[50],
                  backgroundImage: photoData != null ? _buildAvatarImage(photoData) : null,
                  child: photoData == null ? const Icon(Icons.person, size: 20, color: Color(0xFF00695C)) : null,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.name, style: const TextStyle(fontSize: 18))),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: _buildChatBody(photoData),
              ),
              _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  ImageProvider? _buildAvatarImage(String data) {
    if (data.startsWith('http')) return NetworkImage(data);
    try {
      return MemoryImage(base64Decode(data));
    } catch (e) {
      return null;
    }
  }

  /// Builds the list of messages in the conversation.
  Widget _buildChatBody(String? otherPhoto) {
    if (_isInitializing) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    if (_chatId == null) return const Center(child: Text("Initializing chat..."));

    return StreamBuilder<QuerySnapshot>(
      // Stream messages from the 'messages' sub-collection of this chat
      stream: _chatService.getMessages(_chatId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final messages = snapshot.data!.docs;
        final currentUid = FirebaseAuth.instance.currentUser?.uid;

        return ListView.builder(
          reverse: true, // Show latest messages at the bottom
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index].data() as Map<String, dynamic>;
            final isUser = msg['senderId'] == currentUid;
            final isInquiry = msg['is_inquiry'] == true;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: otherPhoto != null ? _buildAvatarImage(otherPhoto) : null,
                      child: otherPhoto == null ? const Icon(Icons.person, size: 14) : null,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // If it's a post inquiry, show the post summary bubble
                        if (isInquiry) _buildInquiryBubble(msg, isUser),
                        // Show the text message bubble
                        if (!isInquiry) Container(
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
                            msg['text'] ?? "",
                            style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a specialized message bubble showing a post being inquired about.
  Widget _buildInquiryBubble(Map<String, dynamic> msg, bool isUser) {
    final image = msg['post_image'] as String?;
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.shade100, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null && image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: _buildPostImage(image),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg['post_category'] ?? "Inquiry", 
                  style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(msg['post_content']?.toString().isEmpty == true ? "Neighbor is interested!" : (msg['post_content'] ?? ""),
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the image for a post within a chat inquiry.
  Widget _buildPostImage(String path) {
    if (path.length > 500) {
      return Image.memory(base64Decode(path), height: 120, width: double.infinity, fit: BoxFit.cover);
    } else {
      return Image.network(path, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }
  }

  /// Builds the message input field and send button.
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
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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