import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CreateUserState {}

class CreateUserInitial extends CreateUserState {}

class CreateUserLoading extends CreateUserState {}

class CreateUserSuccess extends CreateUserState {}

class CreateUserFailure extends CreateUserState {
  final String message;
  CreateUserFailure(this.message);
}

class CreateUserCubit extends Cubit<CreateUserState> {
  CreateUserCubit() : super(CreateUserInitial());
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String gender,
    required String datetime,
  }) async {
    try {
      emit(CreateUserLoading());
      final supabase = Supabase.instance.client;

      //بنتاكد هوا مسجل بيه قبل كده ولا لا
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        emit(
          CreateUserFailure(
            "⚠️ هذا البريد مسجّل مسبقًا، يمكنك تسجيل الدخول بدلاً من ذلك",
          ),
        );
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

      emit(CreateUserSuccess());
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'validation_failed':
          errorMessage = "❌ البريد الإلكتروني غير صالح";
          break;
        case 'weak_password':
          errorMessage = "❌ كلمة المرور قصيرة جداً";
          break;
        case 'over_email_send_rate_limit':
          errorMessage = "⚠️ هذا البريد مسجل بالفعل، جرّب تسجيل دخول";
          break;
        default:
          errorMessage = "⚠️ خطأ في المصادقة: ${e.message}";
      }
      emit(CreateUserFailure(errorMessage));
    } on SocketException {
      emit(CreateUserFailure("📡 تأكد من اتصال الإنترنت"));
    } on TimeoutException {
      emit(CreateUserFailure("⌛ الاتصال استغرق وقت طويل"));
    } catch (e) {
      emit(CreateUserFailure("⚠️ خطأ غير متوقع: $e"));
    }
  }
}
