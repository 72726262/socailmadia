import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:soso/model/CommentModel.dart';
import 'package:soso/services/comment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsScreen extends StatefulWidget {
  static const routeName = "CommentsScreen";
  final Map<String, dynamic> post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool get isArabic => appLocale.value.languageCode == 'ar';
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();

  Stream<List<Comment>>? _commentsStream;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  @override
  void dispose() {
    _commentService.disposeStream(widget.post['id']);
    super.dispose();
  }

  void _initializeStream() {
    _commentsStream = _commentService.getCommentsStreamByPostId(
      widget.post['id'],
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addComment(String text) async {
    if (text.trim().isEmpty) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final success = await _commentService.addComment(
      postId: widget.post['id'],
      userId: currentUser.id,
      content: text.trim(),
      fullname: widget.post["fullname"] ?? "User",
      userimage: widget.post['userimage'] ?? "",
    );

    if (success) {
      _commentController.clear();
      // مفيش حاجة هنا - الـ Stream هيحدث تلقائياً
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'فشل في إضافة التعليق' : 'Failed to add comment',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final success = await _commentService.deleteComment(
      commentId,
      widget.post['id'],
    );
    if (success) {
      // مفيش حاجة هنا - الـ Stream هيحدث تلقائياً
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم حذف التعليق' : 'Comment deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'فشل في حذف التعليق' : 'Failed to delete comment',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(isArabic ? "التعليقات" : "Comments"),
        backgroundColor: const Color(0xFF0066FF),
      ),
      body: Column(
        children: [
          // عدد التعليقات
          StreamBuilder<List<Comment>>(
            stream: _commentsStream,
            builder: (context, snapshot) {
              final count = snapshot.hasData ? snapshot.data!.length : 0;
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Text(
                  isArabic ? "$count تعليق" : "$count comments",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066FF),
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Comment>>(
                    stream: _commentsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                isArabic
                                    ? 'لا توجد تعليقات'
                                    : 'No comments yet',
                              ),
                            ],
                          ),
                        );
                      }

                      final comments = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final isMyComment =
                              comment.userId ==
                              Supabase.instance.client.auth.currentUser?.id;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: comment.userimage == null
                                      ? AssetImage("assets/avatar.png")
                                            as ImageProvider
                                      : NetworkImage(comment.userimage!),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            comment.fullname,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (isMyComment)
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _deleteComment(comment.id),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(comment.content),
                                      SizedBox(height: 4),
                                      Text(
                                        _formatTime(comment.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
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
                  ),
          ),

          // حقل الإدخال
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              left: 16,
              right: 16,
              top: 10,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: isArabic
                          ? "اكتب تعليق..."
                          : "Write a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Color(0xFF0066FF),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => _addComment(_commentController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return isArabic ? "الآن" : "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}${isArabic ? " د" : "m"}";
    if (diff.inHours < 24) return "${diff.inHours}${isArabic ? " س" : "h"}";
    return "${diff.inDays}${isArabic ? " ي" : "d"}";
  }
}
