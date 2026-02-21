import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum ProfileType {
  universal,
  cyclist,
  hiker,
  driver,
  nautical,
  paraglider,
  camper,
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    required ProfileType type,
    @Default([]) List<String> defaultLayers,
    @Default({}) Map<String, double> alertThresholds,
    @Default('km/h') String speedUnit,
    @Default('°C') String tempUnit,
    @Default('km') String distanceUnit,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
