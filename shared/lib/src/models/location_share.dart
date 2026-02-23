import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/location_share_type.dart';

part 'location_share.g.dart';

/// Represents a location share from a user within a space.
@JsonSerializable()
class LocationShare extends Equatable {
  const LocationShare({
    required this.id,
    required this.userId,
    required this.spaceId,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.expiresAt,
    this.etaDestination,
    this.etaMinutes,
    required this.createdAt,
  });

  factory LocationShare.fromJson(Map<String, dynamic> json) =>
      _$LocationShareFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  @JsonKey(name: 'type')
  final LocationShareType type;

  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  @JsonKey(name: 'eta_destination')
  final String? etaDestination;

  @JsonKey(name: 'eta_minutes')
  final int? etaMinutes;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$LocationShareToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    spaceId,
    latitude,
    longitude,
    type,
    expiresAt,
    etaDestination,
    etaMinutes,
    createdAt,
  ];
}
