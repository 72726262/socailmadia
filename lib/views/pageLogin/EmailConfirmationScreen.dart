import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:soso/views/pageLogin/LoginPage.dart';

class EmailConfirmationScreen extends StatelessWidget {
  static const routeName = "EmailConfirmationScreen";

  bool get isArabic => appLocale.value.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final bool isArabic = appLocale.value.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 90, color: Colors.blueAccent),

              const SizedBox(height: 20),

              Text(
                isArabic
                    ? "تحقق من بريدك الإلكتروني 📩"
                    : "Check Your Email 📩",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                isArabic
                    ? "قمنا بإرسال رابط التحقق إلى بريدك.\nيرجى تأكيد حسابك لإكمال التسجيل."
                    : "We sent a verification link to your email.\nPlease confirm your account.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, LoginPage.routeName);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isArabic ? "استمر" : "Next",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
