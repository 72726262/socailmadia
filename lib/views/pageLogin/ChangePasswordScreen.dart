import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = "ChangePasswordScreen";

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;

  late AnimationController _anim;
  late Animation<double> fade;

  bool get isArabic => appLocale.value.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    if (_anim.isAnimating || !_anim.isDismissed) {
      _anim.stop();
    }
    _anim.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(String phone) async {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? "كلمة المرور قصيرة جداً" : "Password too short",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? "كلمة المرور غير متطابقة" : "Passwords do not match",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // ✅ تغيير كلمة المرور باستخدام Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "تم تغيير كلمة المرور بنجاح"
                : "Password updated successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // العودة لشاشة تسجيل الدخول
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/LoginPage",
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "حدث خطأ أثناء تغيير كلمة المرور"
                : "Failed to change password",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: FadeTransition(
        opacity: fade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF2F6FF), Color(0xFFE8EFFF), Color(0xFFDDE7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // زر تغيير اللغة
                Align(
                  alignment: isArabic ? Alignment.topRight : Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      bool arabic = appLocale.value.languageCode == 'ar';
                      appLocale.value = arabic
                          ? const Locale('en', 'US')
                          : const Locale('ar', 'EG');
                      setState(() {});
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: isArabic
                          ? [
                              const Icon(
                                Icons.language,
                                size: 28,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "English",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ]
                          : [
                              Text(
                                "العربية",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.language,
                                size: 28,
                                color: Colors.black87,
                              ),
                            ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  isArabic ? "كلمة المرور الجديدة 🔑" : "New Password 🔑",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  isArabic
                      ? "أدخل كلمة المرور الجديدة وأكدها."
                      : "Enter and confirm your new password.",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const SizedBox(height: 35),

                // حقل كلمة المرور الجديدة
                _passwordField(
                  label: isArabic ? "كلمة المرور" : "Password",
                  controller: _passwordController,
                  hide: hidePassword,
                  toggle: () => setState(() => hidePassword = !hidePassword),
                ),

                const SizedBox(height: 20),

                // حقل تأكيد كلمة المرور
                _passwordField(
                  label: isArabic ? "تأكيد كلمة المرور" : "Confirm Password",
                  controller: _confirmController,
                  hide: hideConfirm,
                  toggle: () => setState(() => hideConfirm = !hideConfirm),
                ),

                const SizedBox(height: 40),

                GestureDetector(
                  onTap: () => _changePassword(phone),
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      isArabic ? "تأكيد التغيير" : "Confirm Change",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool hide,
    required VoidCallback toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: hide,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: GestureDetector(
            onTap: toggle,
            child: Icon(
              hide ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
