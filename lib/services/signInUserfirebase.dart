import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soso/Cubit/cubitsignInuser.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class Signinuserfirebase extends Cubit<counterstate2> {
  String? error22;
  Signinuserfirebase(super.initialState);

  Future<void> signIn({required String email, required String password}) async {
    try {
      emit(counterstateLoding2());

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // SharedprefencesSingleton.setBool(keyonBorderingViewsee, true);
      emit(counterstateSuccuss2());
    } on AuthException catch (e) {
      emit(counterstateFaliuer2());
      if (e.code == 'invalid_credentials') {
        error22 = "❌ البريد الإلكتروني أو كلمة المرور غير صحيحة";
      } else if (e.code == 'user_not_found') {
        error22 = "❌ المستخدم غير موجود";
      } else if (e.code == 'email_not_confirmed') {
        error22 = "📧 البريد الإلكتروني غير مؤكد، تحقق من صندوق الوارد";
      } else if (e.code == 'too_many_requests') {
        error22 = "⚠️ محاولات كثيرة، حاول لاحقًا";
      } else if (e.code == 'validation_failed') {
        error22 = "❌ البريد الإلكتروني غير صالح";
      } else {
        error22 = "⚠️ خطأ في تسجيل الدخول: ${e.message}";
      }
    } on SocketException {
      emit(counterstateFaliuer2());
      error22 = "📡 تأكد من اتصال الإنترنت";
    } on TimeoutException {
      emit(counterstateFaliuer2());
      error22 = "⌛ الاتصال استغرق وقت طويل";
    } catch (e) {
      emit(counterstateFaliuer2());

      error22 = "⚠️ خطأ غير متوقع: $e";
    }
  }
}
