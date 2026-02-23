import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:weathernav/data/repositories/settings_repository_hive.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';

part 'settings_repository_provider.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return HiveSettingsRepository();
}
