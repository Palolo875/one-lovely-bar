import 'package:hive_ce/hive.dart';

Future<void> purgeCacheBox(
  Box<Object?> box, {
  Duration maxAge = const Duration(days: 7),
}) async {
  final now = DateTime.now();
  final toDelete = <Object?>[];

  for (final key in box.keys) {
    final v = box.get(key);
    if (v is Map) {
      final ts = v['ts'];
      if (ts is int) {
        final age = now.difference(DateTime.fromMillisecondsSinceEpoch(ts));
        if (age > maxAge) {
          toDelete.add(key);
        }
      }
    }
  }

  if (toDelete.isNotEmpty) {
    await box.deleteAll(toDelete);
  }
}
