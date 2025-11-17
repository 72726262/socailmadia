import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soso/Cubit/cubitcreateuser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateUserFirebase extends Cubit<counterstate> {
  String? error22;
  CreateUserFirebase(super.initialState);

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String gender,
    required String datetime,
  }) async {
    try {
      emit(counterstateLoding());
      final supabase = Supabase.instance.client;

      //بنتاكد هوا مسجل بيه قبل كده ولا لا
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        error22 = "⚠️ هذا البريد مسجّل مسبقًا، يمكنك تسجيل الدخول بدلاً من ذلك";
        emit(counterstateFaliuer());
        return;
      }

      // 🟢 إنشاء حساب جديد
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        await supabase.from('users').insert({
          "uid": user.id,
          "fullname": fullName,
          "email": user.email,
          "gender": gender,
          "datetime": datetime,
        });
      }

      emit(counterstateSuccuss());
    } on AuthException catch (e) {
      emit(counterstateFaliuer());
      switch (e.code) {
        case 'validation_failed':
          error22 = "❌ البريد الإلكتروني غير صالح";
          break;
        case 'weak_password':
          error22 = "❌ كلمة المرور قصيرة جداً";
          break;
        case 'over_email_send_rate_limit':
          error22 = "⚠️ هذا البريد مسجل بالفعل، جرّب تسجيل دخول";
          break;
        default:
          error22 = "⚠️ خطأ في المصادقة: ${e.message}";
      }
    } on SocketException {
      emit(counterstateFaliuer());
      error22 = "📡 تأكد من اتصال الإنترنت";
    } on TimeoutException {
      emit(counterstateFaliuer());
      error22 = "⌛ الاتصال استغرق وقت طويل";
    } catch (e) {
      emit(counterstateFaliuer());
      error22 = "⚠️ خطأ غير متوقع: $e";
    }
  }
}
