import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart' as intl; // استخدام اسم مستعار لتجنب التعارض
import 'package:soso/model/UserModel.dart';
import 'package:soso/main.dart';
import 'package:soso/services/chat_service.dart';
import 'package:soso/widgets/ChatScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListScreen extends StatefulWidget {
  static const routeName = "ChatListScreen";

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  late final Stream<List<Map<String, dynamic>>> _chatsStream;
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _chatsStream = _chatService.getUserChats(_currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = appLocale.value.languageCode == "ar";

    return Directionality(
      textDirection: isArabic
          ? TextDirection.rtl
          : TextDirection.ltr, // الآن سيعمل بشكل صحيح
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6FF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0066FF),
          title: Text(
            isArabic ? "المحادثات" : "Chats",
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _chatsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildChatsSkeleton();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildAllUsersList(isArabic);
            }

            final chats = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return FutureBuilder<UserModel?>(
                  future: _chatService.getChatUserInfo(
                    chat['id'],
                    _currentUserId,
                  ),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return _buildChatTileSkeleton();
                    }
                    final otherUser = userSnapshot.data;
                    return otherUser != null
                        ? _buildChatTile(otherUser)
                        : const SizedBox.shrink();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatTile(UserModel user) {
    // ⭐ تم إرجاع الدالة لحالتها الأصلية
    return GestureDetector(
      onTap: () {
        Navigator.push(
          // ⭐ تم إرجاع الدالة لحالتها الأصلية
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              user: {
                "uid": user.id,
                "fullname": user.fullname,
                "imageurl": user.imageUrl,
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: user.imageUrl != null
                  ? NetworkImage(user.imageUrl!)
                  : null,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullname,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Last message...", // ⭐ تم إرجاع النص الثابت
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
          ],
        ),
      ),
    );
  }

  // ⭐ جديد: دالة لعرض كل المستخدمين في حالة عدم وجود محادثات
  Widget _buildAllUsersList(bool isArabic) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _chatService.getAllUsers(),
      builder: (context, usersSnapshot) {
        if (usersSnapshot.connectionState == ConnectionState.waiting) {
          return _buildChatsSkeleton();
        }

        if (!usersSnapshot.hasData || usersSnapshot.data!.isEmpty) {
          return Center(
            child: Text(
              isArabic ? "لا يوجد مستخدمون آخرون" : "No other users found",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final allUsers = usersSnapshot.data!
            .map((userMap) => UserModel.fromMap(userMap))
            .toList();

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: allUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = allUsers[index];
            return _buildNewChatUserTile(user);
          },
        );
      },
    );
  }

  // ⭐ جديد: واجهة المستخدم لكل مستخدم جديد لبدء محادثة
  Widget _buildNewChatUserTile(UserModel user) {
    bool isArabic = appLocale.value.languageCode == "ar";
    return GestureDetector(
      onTap: () => _navigateToChat(user),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: user.imageUrl != null
                  ? NetworkImage(user.imageUrl!)
                  : null,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullname,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic ? "اضغط لبدء محادثة" : "Tap to start chatting",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_comment_outlined,
                color: Color(0xFF0066FF),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildChatTileSkeleton(),
      ),
    );
  }

  Widget _buildChatTileSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ جديد: دالة للانتقال إلى شاشة الشات
  void _navigateToChat(UserModel otherUser) async {
    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // جلب أو إنشاء محادثة
      await _chatService.getOrCreateChat(_currentUserId, otherUser.id);

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // الانتقال لشاشة الشات
      if (mounted) {
        // التحقق من أن الويدجت ما زال موجوداً
        // التحقق من أن الويدجت ما زال موجوداً
        // التحقق من أن الويدجت ما زال موجوداً
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              user: {
                "uid": otherUser.id,
                "fullname": otherUser.fullname,
                "imageurl": otherUser.imageUrl,
              },
            ),
          ),
        );
      }
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: $e')),
        ); // ⭐ تم إرجاع رسالة الخطأ
      }
    }
  }
}
