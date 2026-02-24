import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/access_level.dart';
import '../enums/member_role.dart';
import '../enums/membership_status.dart';

part 'space_membership.freezed.dart';
part 'space_membership.g.dart';

/// Represents a user's membership in a space.
@freezed
abstract class SpaceMembership with _$SpaceMembership {
  const factory SpaceMembership({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'user_id') required String userId,
    required MemberRole role,
    @JsonKey(name: 'access_level') required AccessLevel accessLevel,
    required MembershipStatus status,
    @JsonKey(name: 'invited_by') String? invitedBy,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'left_at') DateTime? leftAt,
  }) = _SpaceMembership;

  factory SpaceMembership.fromJson(Map<String, dynamic> json) =>
      _$SpaceMembershipFromJson(json);
}
