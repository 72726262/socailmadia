import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:soso/widgets/ChatScreen.dart';

class ChatListScreen extends StatelessWidget {
  static const routeName = "ChatListScreen";

  final List<Map<String, String>> users = [
    {
      "name": "Alice",
      "avatar": "assets/avatar1.png",
      "lastMessage": "Hey, how are you?",
    },
    {
      "name": "Bob",
      "avatar": "assets/avatar2.png",
      "lastMessage": "Let's meet tomorrow!",
    },
    {
      "name": "Charlie",
      "avatar": "assets/avatar3.png",
      "lastMessage": "Good night 🌙",
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isArabic = appLocale.value.languageCode == "ar";

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6FF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0066FF),
          title: Text(isArabic ? "المحادثات" : "Chats"),
          centerTitle: true,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ChatScreen.routeName,
                  arguments: {
                    "name": "Akram Atiia",
                    "avatar": "assets/avatar.png",
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
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
                      backgroundImage: AssetImage(user["avatar"]!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user["name"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user["lastMessage"]!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
