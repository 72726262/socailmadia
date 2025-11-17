import 'package:soso/model/selectUsermodeale.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Selecteuserssereverse {
  Stream<List<SelectUsermodale>> getuserStream() {
    final stream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['id'])
        .neq('uid', Supabase.instance.client.auth.currentUser!.id)
        .order('id', ascending: true);

    return stream.map((data) {
      return data.map((item) => SelectUsermodale.fromMap(item)).toList();
    });
  }

  Stream<SelectUsermodale> getuser() {
    final stream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('uid', Supabase.instance.client.auth.currentUser!.id)
        .distinct();

    return stream.map((data) {
      return data.map((item) => SelectUsermodale.fromMap(item)).first;
    });
  }
}
