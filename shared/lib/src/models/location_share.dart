import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/location_share_type.dart';

part 'location_share.freezed.dart';
part 'location_share.g.dart';

/// Represents a location share from a user within a space.
@freezed
abstract class LocationShare with _$LocationShare {
  const factory LocationShare({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'space_id') required String spaceId,
    required double latitude,
    required double longitude,
    required LocationShareType type,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'eta_destination') String? etaDestination,
    @JsonKey(name: 'eta_minutes') int? etaMinutes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _LocationShare;

  factory LocationShare.fromJson(Map<String, dynamic> json) =>
      _$LocationShareFromJson(json);
}
