import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/space_type.dart';

part 'space.freezed.dart';
part 'space.g.dart';

/// Represents a shared space between users.
@freezed
abstract class Space with _$Space {
  const factory Space({
    required String id,
    required String name,
    required SpaceType type,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'invite_code') String? inviteCode,
    @JsonKey(name: 'max_members') required int maxMembers,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Space;

  factory Space.fromJson(Map<String, dynamic> json) => _$SpaceFromJson(json);
}
