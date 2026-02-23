import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/size_system.dart';

part 'health_profile.g.dart';

/// Represents a user's health and sizing profile within a space.
@JsonSerializable()
class HealthProfile extends Equatable {
  const HealthProfile({
    required this.id,
    required this.userId,
    required this.spaceId,
    this.heightCm,
    this.weightKg,
    this.topSize,
    this.bottomSize,
    this.underwearSize,
    this.shoeSize,
    this.sizeSystem,
    this.ringSize,
    this.ringSizeSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthProfile.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'height_cm')
  final double? heightCm;

  @JsonKey(name: 'weight_kg')
  final double? weightKg;

  @JsonKey(name: 'top_size')
  final String? topSize;

  @JsonKey(name: 'bottom_size')
  final String? bottomSize;

  @JsonKey(name: 'underwear_size')
  final String? underwearSize;

  @JsonKey(name: 'shoe_size')
  final String? shoeSize;

  @JsonKey(name: 'size_system')
  final SizeSystem? sizeSystem;

  @JsonKey(name: 'ring_size')
  final String? ringSize;

  @JsonKey(name: 'ring_size_system')
  final String? ringSizeSystem;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$HealthProfileToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    spaceId,
    heightCm,
    weightKg,
    topSize,
    bottomSize,
    underwearSize,
    shoeSize,
    sizeSystem,
    ringSize,
    ringSizeSystem,
    createdAt,
    updatedAt,
  ];
}
