import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository_hive.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return HiveSettingsRepository();
});
