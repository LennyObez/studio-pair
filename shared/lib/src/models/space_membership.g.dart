// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpaceMembership _$SpaceMembershipFromJson(Map<String, dynamic> json) =>
    _SpaceMembership(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      userId: json['user_id'] as String,
      role: $enumDecode(_$MemberRoleEnumMap, json['role']),
      accessLevel: $enumDecode(_$AccessLevelEnumMap, json['access_level']),
      status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
      invitedBy: json['invited_by'] as String?,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      leftAt: json['left_at'] == null
          ? null
          : DateTime.parse(json['left_at'] as String),
    );

Map<String, dynamic> _$SpaceMembershipToJson(_SpaceMembership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'space_id': instance.spaceId,
      'user_id': instance.userId,
      'role': _$MemberRoleEnumMap[instance.role]!,
      'access_level': _$AccessLevelEnumMap[instance.accessLevel]!,
      'status': _$MembershipStatusEnumMap[instance.status]!,
      'invited_by': instance.invitedBy,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'left_at': instance.leftAt?.toIso8601String(),
    };

const _$MemberRoleEnumMap = {
  MemberRole.owner: 'owner',
  MemberRole.admin: 'admin',
  MemberRole.member: 'member',
};

const _$AccessLevelEnumMap = {
  AccessLevel.readOnly: 'read_only',
  AccessLevel.readWrite: 'read_write',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.active: 'active',
  MembershipStatus.invited: 'invited',
  MembershipStatus.left: 'left',
  MembershipStatus.removed: 'removed',
};
