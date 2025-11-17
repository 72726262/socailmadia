import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = "ChatScreen";
  final Map<String, dynamic> user;

  ChatScreen({required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool get isArabic => appLocale.value.languageCode == 'ar';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [
    {"type": "text", "content": "Hello!", "isMe": false},
    {"type": "text", "content": "Hi! How are you?", "isMe": true},
    {"type": "image", "content": "https://picsum.photos/200", "isMe": false},
  ];

  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return; // لو في picker شغال، ما تعملش حاجة
    _isPickingImage = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // اعمل اللي تحب بالـ image
      }
    } catch (e) {
      print("Error picking image: $e");
    } finally {
      _isPickingImage = false; // رجع flag عشان المستخدم يقدر يضغط مرة تانية
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      messages.add({
        "type": "text",
        "content": _messageController.text,
        "isMe": true,
      });
      _messageController.clear();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> user =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0066FF),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(widget.user['avatar']!),
              ),
              const SizedBox(width: 12),
              Text(widget.user['name']!),
            ],
          ),
        ),
        body: Column(
          children: [
            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  bool isMe = msg['isMe'];
                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: msg['type'] == 'text'
                          ? const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            )
                          : const EdgeInsets.all(4),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? Color(0xFF0066FF) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: msg['type'] == 'text'
                          ? Text(
                              msg['content'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: msg['content'].startsWith("http")
                                  ? Image.network(msg['content'])
                                  : Image.file(File(msg['content'])),
                            ),
                    ),
                  );
                },
              ),
            ),

            // Input Area
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Color(0xFF0066FF)),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: isArabic
                              ? "اكتب رسالة..."
                              : "Type a message...",
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF0066FF)),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
