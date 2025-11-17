import 'package:soso/model/seelcteMassagesusers.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class Selectmassagesservisec {
  Stream<List<seelcteMassagesusers>> getmassagesStream(String chatId) {
    final stream = Supabase.instance.client
        .from('chatusers')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .distinct();

    return stream.map((data) {
      return data.map((item) => seelcteMassagesusers.fromMap(item)).toList();
    });
  }
}
