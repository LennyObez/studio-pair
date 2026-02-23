import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/space_type.dart';

part 'space.g.dart';

/// Represents a shared space between users.
@JsonSerializable()
class Space extends Equatable {
  const Space({
    required this.id,
    required this.name,
    required this.type,
    this.avatarUrl,
    this.inviteCode,
    required this.maxMembers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Space.fromJson(Map<String, dynamic> json) => _$SpaceFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'type')
  final SpaceType type;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'invite_code')
  final String? inviteCode;

  @JsonKey(name: 'max_members')
  final int maxMembers;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$SpaceToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    avatarUrl,
    inviteCode,
    maxMembers,
    createdAt,
    updatedAt,
  ];
}
