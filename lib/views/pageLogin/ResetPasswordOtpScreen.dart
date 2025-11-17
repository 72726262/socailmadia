import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:soso/views/pageLogin/ChangePasswordScreen.dart';

class ResetPasswordOtpScreen extends StatefulWidget {
  static const routeName = "ResetPasswordOtpScreen";

  @override
  State<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends State<ResetPasswordOtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
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
    _anim.dispose();
    _otpController.dispose();

    super.dispose();
  }

  void _verifyOtp(String phone) {
    if (_otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? "الرمز غير صحيح" : "Invalid OTP code"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // بعد التحقق من OTP → ننتقل لصفحة تغيير كلمة المرور
    Navigator.pushNamed(context, "/ChangePasswordScreen", arguments: phone);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // زر تغيير اللغة
              Align(
                alignment: isArabic ? Alignment.topRight : Alignment.topLeft,
                child: GestureDetector(
                  onTap: () async {
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
                isArabic
                    ? "أدخل الرمز المرسل إلى هاتفك 🔐"
                    : "Enter OTP sent to your phone 🔐",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                isArabic
                    ? "لقد أرسلنا رمز تحقق إلى الرقم: $phone"
                    : "We sent a verification code to: $phone",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 40),

              // حقل OTP
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isArabic ? "رمز التحقق" : "OTP Code",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // زر التحقق
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ChangePasswordScreen.routeName,
                    arguments: phone,
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
                    isArabic ? "تحقق" : "Verify",
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
    );
  }
}
