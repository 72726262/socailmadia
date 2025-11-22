import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:skeletonizer/skeletonizer.dart';
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

  late Stream<List<Comment>> _commentsStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeStream() {
    _commentsStream = _commentService.getCommentsStreamByPostId(
      widget.post['id'],
    );
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
      postOwnerId: widget.post['user_id'],
      postImage:
          widget.post['image_url'] ?? "", // ⭐ تصحيح: استخدام المفتاح الصحيح
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
        elevation: 1,
        shadowColor: Colors.black26,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Text(
              isArabic ? "التعليقات" : "Comments",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0066FF),
      ),
      body: Column(
        children: [
          // ⭐ جديد: عرض المنشور الأصلي في الأعلى
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildPostHeader()),
                const SliverToBoxAdapter(
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
                StreamBuilder<List<Comment>>(
                  stream: _commentsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return _buildCommentsSkeleton(); // ⭐ استخدام الواجهة الهيكلية هنا
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text('Error: ${snapshot.error}')),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
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
                        ),
                      );
                    }

                    final comments = snapshot.data!;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final comment = comments[index];
                        final isMyComment =
                            comment.userId ==
                            Supabase.instance.client.auth.currentUser?.id;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(24, 207, 199, 199),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.fullname,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        if (isMyComment)
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              size: 25,
                                              color: Colors.red,
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
                                        fontSize: 14,
                                        color: const Color.fromARGB(
                                          255,
                                          85,
                                          84,
                                          84,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: comments.length),
                    );
                  },
                ),
              ],
            ),
          ),

          // حقل الإدخال
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: 10, // مسافة بسيطة ثابتة أسفل الصندوق
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

  // ⭐ جديد: دالة لبناء الجزء العلوي الذي يعرض المنشور
  Widget _buildPostHeader() {
    final post = widget.post;
    final hasImage =
        post['image_url'] != null && post['image_url'].toString().isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات صاحب المنشور
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: post['userimage'] != null
                    ? NetworkImage(post['userimage'])
                    : null,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['fullname'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(DateTime.parse(post['created_at'])),
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 49, 49, 49),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // محتوى المنشور النصي
          if (post['content'] != null && post['content'].toString().isNotEmpty)
            Text(post['content'], style: const TextStyle(fontSize: 14)),

          if (hasImage) const SizedBox(height: 12),

          // صورة المنشور
          if (hasImage)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['image_url'],
                  fit: BoxFit.fitWidth,

                  height: 200,
                ),
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

  // ⭐ جديد: دالة لبناء الواجهة الهيكلية للتعليقات
  Widget _buildCommentsSkeleton() {
    return SliverToBoxAdapter(
      child: Skeletonizer(
        enabled: true,
        child: ListView.builder(
          shrinkWrap: true, // ⭐ مهم: لمنع ListView من أخذ مساحة لا نهائية
          physics:
              const NeverScrollableScrollPhysics(), // ⭐ مهم: لمنع التمرير المزدوج
          padding: const EdgeInsets.all(16),
          itemCount: 5, // عرض 5 عناصر هيكلية
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم وهمي
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: 8),
                        // محتوى وهمي
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        SizedBox(height: 6),
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
          },
        ),
      ),
    );
  }
}
