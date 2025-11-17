import 'package:soso/model/selectestoryModale.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<Story>> getStoriesStream() {
    final stream = supabase
        .from('stories')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);

    return stream.map((event) {
      final now = DateTime.now();
      final list = (event as List).map((e) => Story.fromMap(e)).toList();

      // فلترة محلياً على الحقول اللي فيها expiresAt
      final filtered = list.where((s) => s.expiresAt.isAfter(now)).toList();
      return filtered;
    });
  }

  Stream<List<Story>> getUserStoriesStream(String userId) {
    final stream = supabase
        .from('stories')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);

    return stream.map((event) {
      final now = DateTime.now();
      final list = (event as List).map((e) => Story.fromMap(e)).toList();

      // فلترة بحسب user_id وكمان expiresAt
      final filtered = list
          .where((s) => s.userId == userId && s.expiresAt.isAfter(now))
          .toList();
      return filtered;
    });
  }
}
