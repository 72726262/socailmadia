import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AddStories {
  final SupabaseClient supabase = Supabase.instance.client;

  /// فتح الاستديو لاختيار صورة
  Future<File?> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  /// رفع الصورة على الـ Supabase Storage
  Future<String?> uploadStoryImage(File file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      await supabase.storage
          .from('story/image')
          .upload(fileName, file, fileOptions: FileOptions(upsert: true));

      final publicUrl = supabase.storage
          .from('story/image')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await supabase
          .from('users')
          .select('fullname, image')
          .eq('uid', Supabase.instance.client.auth.currentUser!.id)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// إضافة الستوري للجدول
  Future<bool> addStoryToDatabase({
    required String userId,
    required String imageUrl,
    required String userName,
    required String userImage,
  }) async {
    try {
      // 1️⃣ هات بيانات المستخدم

      // 2️⃣ وقت الاضافة
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      // 3️⃣ الإضافة إلى جدول stories
      final response = await supabase.from('stories').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'created_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'userName': userName,
        'userImage': userImage,
      }).select();

      if (response.isNotEmpty) {
        print("Story inserted successfully: $response");
        return true;
      } else {
        print("Insert failed: $response");
        return false;
      }
    } catch (e) {
      print("Error saving story to database: $e");
      return false;
    }
  }

  /// الوظيفة الكاملة: اختيار الصورة، رفعها، وحفظها
  Future<bool> addStory({
    required String userId,
    required String userName,
    required String userImage,
  }) async {
    try {
      final file = await pickImage();
      if (file == null) return false;

      final imageUrl = await uploadStoryImage(file);
      if (imageUrl == null) return false;

      final success = await addStoryToDatabase(
        userId: userId,
        imageUrl: imageUrl,
        userName: userName,
        userImage: userImage,
      );
      return success;
    } catch (e) {
      return false;
    }
  }

  /// الوظيفة النهائية لزر الإضافة: تتضمن التعامل مع الرسالة تلقائيًا
  Future<void> handleAddStory({
    required BuildContext context,
    required String userName,
    required String userImage,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      showAnimatedStoryMessage(context, "يجب تسجيل الدخول أولاً!");
      return;
    }

    final success = await addStory(
      userId: userId,
      userName: userName,
      userImage: userImage,
    );

    if (success == true) {
      showAnimatedStoryMessage(context, "تم إضافة الاستوري بنجاح!");
    } else {
      showAnimatedStoryMessage(context, "فشل إضافة الاستوري، حاول مرة أخرى");
    }
  }
}

void showAnimatedStoryMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  // إنشاء OverlayEntry
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return Center(
        child: _AnimatedStoryMessage(
          message: message,
          onDismissed: () => overlayEntry.remove(),
        ),
      );
    },
  );

  // إدراج OverlayEntry
  overlay.insert(overlayEntry);
}

class _AnimatedStoryMessage extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const _AnimatedStoryMessage({
    required this.message,
    required this.onDismissed,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedStoryMessage> createState() => _AnimatedStoryMessageState();
}

class _AnimatedStoryMessageState extends State<_AnimatedStoryMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    // بعد ثانيتين يتم الإخفاء
    Future.delayed(const Duration(seconds: 5), () {
      _controller.reverse().then((_) => widget.onDismissed());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.purpleAccent.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
