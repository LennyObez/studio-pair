import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/size_system.dart';

part 'health_profile.freezed.dart';
part 'health_profile.g.dart';

/// Represents a user's health and sizing profile within a space.
@freezed
abstract class HealthProfile with _$HealthProfile {
  const factory HealthProfile({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'height_cm') double? heightCm,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'top_size') String? topSize,
    @JsonKey(name: 'bottom_size') String? bottomSize,
    @JsonKey(name: 'underwear_size') String? underwearSize,
    @JsonKey(name: 'shoe_size') String? shoeSize,
    @JsonKey(name: 'size_system') SizeSystem? sizeSystem,
    @JsonKey(name: 'ring_size') String? ringSize,
    @JsonKey(name: 'ring_size_system') String? ringSizeSystem,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _HealthProfile;

  factory HealthProfile.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileFromJson(json);
}
