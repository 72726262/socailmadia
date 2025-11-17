import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneOtpScreen extends StatefulWidget {
  static const routeName = "PhoneOtpScreen";

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;

  late AnimationController _anim;
  late Animation<double> fade;

  bool get isArabic => appLocale.value.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> verifyCode(String phone) async {
    try {
      setState(() => isLoading = true);

      await Supabase.instance.client.auth.verifyOTP(
        token: _codeController.text.trim(),
        type: OtpType.sms,
        phone: phone,
      );

      Navigator.pushReplacementNamed(context, "/Home");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? "الكود غير صحيح" : "Invalid verification code",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: FadeTransition(
        opacity: fade,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 26, vertical: 70),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF2F6FF), Color(0xFFE2EBFF), Color(0xFFD4E1FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          // ---------------------------------------------------------------
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ العنوان
              Text(
                isArabic ? "تأكيد رقم الهاتف 📱" : "Verify Your Phone 📱",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),

              SizedBox(height: 10),

              Text(
                isArabic
                    ? "تم إرسال كود التحقق إلى رقمك:"
                    : "A verification code was sent to:",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              SizedBox(height: 6),

              Text(
                phone,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066FF),
                ),
              ),

              SizedBox(height: 40),

              // ✅ صندوق إدخال OTP
              Container(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, letterSpacing: 4),
                  decoration: InputDecoration(
                    hintText: isArabic ? "••••••" : "••••••",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 40),

              // ✅ زر التحقق
              GestureDetector(
                onTap: isLoading ? null : () => verifyCode(phone),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : Color(0xFF0066FF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0066FF).withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isArabic ? "تأكيد" : "Verify",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 25),

              // ✅ إعادة إرسال الكود
              TextButton(
                onPressed: () {
                  // ✅ إعادة إرسال كود (هنضيفه لو عايز)
                },
                child: Text(
                  isArabic ? "إعادة إرسال الكود" : "Resend Code",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0066FF),
                    fontWeight: FontWeight.w600,
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
