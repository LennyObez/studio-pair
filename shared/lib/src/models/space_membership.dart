import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/access_level.dart';
import '../enums/member_role.dart';
import '../enums/membership_status.dart';

part 'space_membership.g.dart';

/// Represents a user's membership in a space.
@JsonSerializable()
class SpaceMembership extends Equatable {
  const SpaceMembership({
    required this.id,
    required this.spaceId,
    required this.userId,
    required this.role,
    required this.accessLevel,
    required this.status,
    this.invitedBy,
    this.joinedAt,
    this.leftAt,
  });

  factory SpaceMembership.fromJson(Map<String, dynamic> json) =>
      _$SpaceMembershipFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'role')
  final MemberRole role;

  @JsonKey(name: 'access_level')
  final AccessLevel accessLevel;

  @JsonKey(name: 'status')
  final MembershipStatus status;

  @JsonKey(name: 'invited_by')
  final String? invitedBy;

  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;

  @JsonKey(name: 'left_at')
  final DateTime? leftAt;

  Map<String, dynamic> toJson() => _$SpaceMembershipToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    userId,
    role,
    accessLevel,
    status,
    invitedBy,
    joinedAt,
    leftAt,
  ];
}
