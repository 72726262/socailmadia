import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soso/main.dart';
import 'package:soso/views/pageLogin/ResetPasswordOtpScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPhone extends StatefulWidget {
  static const routeName = "ForgotPasswordPhone";

  @override
  State<ForgotPasswordPhone> createState() => _ForgotPasswordPhoneState();
}

class _ForgotPasswordPhoneState extends State<ForgotPasswordPhone> {
  final _phoneController = TextEditingController();

  bool get isArabic => appLocale.value.languageCode == 'ar';

  Future<void> _sendResetOtp() async {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? "رقم غير صالح" : "Invalid Phone Number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // ✅ إرسال كود اعادة التعيين بالطريقة الجديدة
      await Supabase.instance.client.auth.signInWithOtp(
        phone: _phoneController.text,
        shouldCreateUser: false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? "تم إرسال الكود لهاتفك" : "Reset OTP sent to your phone",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamed(
        context,
        "/ResetPasswordOtpScreen", // هنبعت له صفحة جديدة للـ Reset
        arguments: _phoneController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? "حدث خطأ أثناء الإرسال" : "Failed to send OTP",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------
            // ✅ زر تغيير اللغة + يتحرك حسب اللغة
            // ------------------------------------------------------
            Align(
              alignment: isArabic ? Alignment.topRight : Alignment.topLeft,
              child: GestureDetector(
                onTap: () async {
                  bool arabic = appLocale.value.languageCode == 'ar';
                  appLocale.value = arabic
                      ? const Locale('en', 'US')
                      : const Locale('ar', 'EG');

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString("app_lang", appLocale.value.languageCode);
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
                              color: Colors.grey[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]
                      : [
                          Text(
                            "العربية",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[900],
                              fontWeight: FontWeight.w600,
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

            // ------------------------------------------------------
            // ✅ عنوان الصفحة
            // ------------------------------------------------------
            Text(
              isArabic ? "إعادة تعيين كلمة المرور 🔐" : "Reset Password 🔐",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isArabic
                  ? "أدخل رقم هاتفك وسنرسل لك رمزاً لإعادة التعيين."
                  : "Enter your phone number and we'll send you reset OTP.",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 35),

            // ------------------------------------------------------
            // ✅ حقل رقم الهاتف UI احترافي
            // ------------------------------------------------------
            Container(
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
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isArabic ? "رقم الهاتف" : "Phone Number",
                  prefixIcon: const Icon(Icons.phone),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // زر إرسال الكود
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ResetPasswordOtpScreen.routeName,
                  arguments: _phoneController.text,
                );
              },
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
                  isArabic ? "إرسال الرمز" : "Send OTP",
                  style: const TextStyle(
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
