import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {}

class SignInFailure extends SignInState {
  final String message;
  SignInFailure(this.message);
}

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInInitial());
  Future<void> signIn({required String email, required String password}) async {
    try {
      emit(SignInLoading());

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // SharedprefencesSingleton.setBool(keyonBorderingViewsee, true);
      emit(SignInSuccess());
    } on AuthException catch (e) {
      String errorMessage;
      if (e.code == 'invalid_credentials') {
        errorMessage = "❌ البريد الإلكتروني أو كلمة المرور غير صحيحة";
      } else if (e.code == 'user_not_found') {
        errorMessage = "❌ المستخدم غير موجود";
      } else if (e.code == 'email_not_confirmed') {
        errorMessage = "📧 البريد الإلكتروني غير مؤكد، تحقق من صندوق الوارد";
      } else if (e.code == 'too_many_requests') {
        errorMessage = "⚠️ محاولات كثيرة، حاول لاحقًا";
      } else if (e.code == 'validation_failed') {
        errorMessage = "❌ البريد الإلكتروني غير صالح";
      } else {
        errorMessage = "⚠️ خطأ في تسجيل الدخول: ${e.message}";
      }
      emit(SignInFailure(errorMessage));
    } on SocketException {
      emit(SignInFailure("📡 تأكد من اتصال الإنترنت"));
    } on TimeoutException {
      emit(SignInFailure("⌛ الاتصال استغرق وقت طويل"));
    } catch (e) {
      emit(SignInFailure("⚠️ خطأ غير متوقع: $e"));
    }
  }
}
