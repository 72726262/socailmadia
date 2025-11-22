import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soso/main.dart';
import 'package:soso/model/selectUsermodeale.dart';
import 'package:soso/services/selecteusers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soso/services/PostService.dart';

class AddPostScreen extends StatefulWidget {
  static const routeName = "AddPostScreen";

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool get isArabic => appLocale.value.languageCode == 'ar';

  final TextEditingController _postController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? username;
  String? userimage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  Future<void> _submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? "أضف نص أو صورة للنشر" : "Add text or image to post",
          ),
        ),
      );
      return;
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;
    final ddd = PostService();
    try {
      await ddd.createPost(
        userId: currentUser.id,
        content: text,
        imageFile: _selectedImage,
        userName: username ?? "User",
        imageUser: userimage ?? "",
      );

      _postController.clear();
      setState(() => _selectedImage = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? "تم نشر المنشور!" : "Post submitted!"),
        ),
      );
    } catch (e) {
      print("Error submitting post: ${e}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? "حدث خطأ أثناء النشر" : "Error submitting post",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              isArabic ? "إضافة منشور" : "Add Post",
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
          ),
          backgroundColor: const Color(0xFF0066FF),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات المستخدم
              StreamBuilder<SelectUsermodale?>(
                stream: Selecteuserssereverse().getuser(),
                builder: (context, snapshot) {
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;
                  final user = snapshot.data;

                  if (user == null) {
                    return const SizedBox.shrink();
                  }

                  username = user.name;
                  userimage = user.image;

                  return Skeletonizer(
                    enabled: isLoading,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundImage: NetworkImage(user.image),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // حقل النص
              TextField(
                controller: _postController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: isArabic ? "ماذا تفكر؟" : "What's on your mind?",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // عرض الصورة المختارة
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // أزرار اختيار الصورة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 22,
                    ),
                    label: Text(
                      isArabic ? "كاميرا" : "Camera",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 22,
                    ),
                    label: Text(
                      isArabic ? "معرض الصور" : "Gallery",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // زر النشر
              Center(
                child: ElevatedButton(
                  onPressed: _submitPost,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    child: Text(
                      isArabic ? "نشر" : "Post",
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
