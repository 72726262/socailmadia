import 'package:flutter/material.dart';
import 'package:soso/controllers/notification_controller.dart';
import 'package:soso/widgets/FullScreenImageViewer.dart';
import 'package:intl/intl.dart' as intl; // ⭐ جديد: لاستخدامه في تنسيق الوقت
import 'package:soso/main.dart';

import 'package:skeletonizer/skeletonizer.dart';
import 'package:soso/services/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  static const routeName = "ChatScreen";
  final Map<String, dynamic> user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool get isArabic => appLocale.value.languageCode == 'ar';
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  int? _chatId;
  Stream<List<Map<String, dynamic>>>? _messagesStream;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    NotificationController().setCurrentOpenChat(
      null,
    ); // ⭐ تصحيح: إخبار المتحكم بأن الشات أُغلق
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final currentUser = _chatService.supabase.auth.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // إنشاء أو جلب الشات
      _chatId = await _chatService.getOrCreateChat(
        currentUser.id,
        widget.user['uid'], // ✅ تصحيح: استخدام 'uid' بدلاً من 'id'
      );

      // جلب الـ stream للرسائل
      NotificationController().setCurrentOpenChat(
        _chatId,
      ); // ⭐ تصحيح: إخبار المتحكم بمعرف الشات المفتوح
      _messagesStream = _chatService.getMessagesStream(_chatId!);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null || _isSending)
      return;

    setState(() => _isSending = true);

    try {
      final currentUser = _chatService.supabase.auth.currentUser;
      if (currentUser == null) return;

      await _chatService.sendMessage(
        chatId: _chatId!,
        senderId: currentUser.id,
        text: _messageController.text.trim(),
      );

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في إرسال الرسالة: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ⭐ تعديل: أصبحت الدالة تفتح المعرض وتعرض المعاينة فقط
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // ⭐ جديد: عرض شاشة المعاينة
      _showImagePreview(File(image.path));
    } catch (e) {
      print('Error sending image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في إرسال الصورة: $e')));
    }
  }

  // ⭐ جديد: دالة لعرض الصورة المختارة في BottomSheet للمعاينة
  void _showImagePreview(File imageFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A), // خلفية داكنة احترافية
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // شريط علوي للإغلاق
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // معاينة الصورة
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(imageFile, fit: BoxFit.contain),
                  ),
                ),
              ),
              // زر الإرسال
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context); // إغلاق المعاينة
                    _sendImage(imageFile); // إرسال الصورة
                  },
                  backgroundColor: const Color(0xFF0066FF),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ⭐ جديد: دالة منفصلة لرفع وإرسال الصورة
  Future<void> _sendImage(File imageFile) async {
    if (_chatId == null) return;

    final currentUser = _chatService.supabase.auth.currentUser;
    if (currentUser == null) return;

    setState(() => _isSending = true);
    try {
      final imageUrl = await _chatService.uploadChatImage(imageFile);
      if (imageUrl != null) {
        await _chatService.sendMessage(
          chatId: _chatId!,
          senderId: currentUser.id,
          text: 'صورة', // يمكنك إضافة حقل نصي في المعاينة لتغيير هذا
          imageUrl: imageUrl,
        );
        _scrollToBottom(); // ⭐ تصحيح: التمرير لأسفل بعد إرسال الصورة
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في إرسال الصورة: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ⭐ جديد: دالة لتنسيق وقت الرسالة
  String _formatMessageTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      // استخدام حزمة intl لتنسيق الوقت بشكل مناسب للغة (صباحًا/مساءً)
      return intl.DateFormat.jm(isArabic ? 'ar_EG' : 'en_US').format(dateTime);
    } catch (e) {
      // في حالة حدوث خطأ في التحويل، يتم إرجاع نص فارغ
      return '';
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final heroTag = 'chat_image_${message['id']}'; // ⭐ جديد: Tag فريد لكل صورة
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF0066FF) : Colors.white,
          borderRadius: BorderRadius.circular(18).subtract(
            isMe
                ? const BorderRadius.only(bottomRight: Radius.circular(18))
                : const BorderRadius.only(bottomLeft: Radius.circular(18)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // محتوى الرسالة (صورة أو نص)
            if (message['message_type'] == 'image')
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageViewer(
                        imageUrl: message['image_url'],
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message['image_url'] ?? '',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover, // ⭐ تعديل: استخدام cover لملء المساحة
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              Text(
                message['message_text'] ?? '',
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 20,
                ),
              ),
            const SizedBox(height: 5),
            // وقت الرسالة
            Text(
              _formatMessageTime(message['created_at']),
              style: TextStyle(
                color: isMe
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 0, 0, 0),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading || _messagesStream == null) {
      return _buildMessagesSkeleton();
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              isArabic ? 'لا توجد رسائل بعد' : 'No messages yet',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final messages = snapshot.data!;
        _scrollToBottom(); //لي التمرير لي اسفل عند وجود رساله جديده

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final currentUser = _chatService.supabase.auth.currentUser;
            final isMe =
                currentUser != null && message['sender_id'] == currentUser.id;

            return _buildMessageBubble(message, isMe);
          },
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 25, left: 10, right: 10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Color(0xFF0066FF)), // ⭐ تعديل
            onPressed: _isSending ? null : _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isSending && _chatId != null,
              decoration: InputDecoration(
                hintText: isArabic ? "اكتب رسالة..." : "Type a message...",
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
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: Color(0xFF0066FF)),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  // ⭐ جديد: واجهة هيكلية للرسائل
  Widget _buildMessagesSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _buildSkeletonBubble(isMe: false),
          _buildSkeletonBubble(isMe: true, width: 150),
          _buildSkeletonBubble(isMe: false, width: 200),
          _buildSkeletonBubble(isMe: true),
          _buildSkeletonBubble(isMe: false, width: 120),
          _buildSkeletonBubble(isMe: true, width: 180),
        ],
      ),
    );
  }

  Widget _buildSkeletonBubble({required bool isMe, double? width}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6FF),
        appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0066FF),
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CircleAvatar(
                radius: 25,
                backgroundImage: widget.user['imageurl'] != null
                    ? NetworkImage(widget.user['imageurl'])
                    : null,
                backgroundColor: Colors.white24,
                child: widget.user['imageurl'] == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                widget.user['fullname'] ?? 'User',
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessagesList()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }
}
