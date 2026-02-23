import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'charter.g.dart';

/// Represents a relationship charter for a space.
@JsonSerializable()
class Charter extends Equatable {
  const Charter({
    required this.id,
    required this.spaceId,
    required this.currentVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Charter.fromJson(Map<String, dynamic> json) =>
      _$CharterFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'current_version')
  final int currentVersion;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$CharterToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    currentVersion,
    createdAt,
    updatedAt,
  ];
}
