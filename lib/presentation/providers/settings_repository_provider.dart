import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/data/repositories/settings_repository_hive.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return HiveSettingsRepository();
});
