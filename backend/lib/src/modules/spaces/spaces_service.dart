import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/entitlement_service.dart';
import '../../services/notification_service.dart';
import '../../utils/password_utils.dart';
import 'spaces_repository.dart';

/// Custom exception for space-related errors.
class SpaceException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const SpaceException(
    this.message, {
    this.code = 'SPACE_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'SpaceException($code): $message';
}

/// Service containing all space-related business logic.
class SpacesService {
  final SpacesRepository _repo;
  final EntitlementService _entitlementService;
  final NotificationService _notificationService;
  final Logger _log = Logger('SpacesService');
  final Uuid _uuid = const Uuid();

  /// Valid space types.
  static const _validTypes = [
    'couple',
    'family',
    'polyamorous',
    'friends',
    'roommates',
    'colleagues',
  ];

  /// Valid member roles.
  static const _validRoles = ['owner', 'admin', 'member'];

  /// Valid access levels.
  static const _validAccessLevels = ['read_only', 'read_write'];

  SpacesService(
    this._repo,
    this._entitlementService,
    this._notificationService,
  );

  // ---------------------------------------------------------------------------
  // Space CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new space and adds the creator as owner.
  Future<Map<String, dynamic>> createSpace({
    required String userId,
    required String name,
    required String type,
    String? description,
    String? iconUrl,
  }) async {
    // Validate name
    if (name.trim().isEmpty || name.trim().length < 2) {
      throw const SpaceException(
        'Space name must be at least 2 characters',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    if (name.trim().length > 100) {
      throw const SpaceException(
        'Space name must be at most 100 characters',
        code: 'INVALID_NAME',
        statusCode: 422,
      );
    }

    // Validate type
    if (!_validTypes.contains(type)) {
      throw SpaceException(
        'Invalid space type. Must be one of: ${_validTypes.join(", ")}',
        code: 'INVALID_TYPE',
        statusCode: 422,
      );
    }

    final spaceId = _uuid.v4();

    // Create the space
    final space = await _repo.createSpace(
      id: spaceId,
      name: name.trim(),
      type: type,
      description: description?.trim(),
      iconUrl: iconUrl,
    );

    // Add creator as owner
    final membership = await _repo.addMember(
      spaceId: spaceId,
      userId: userId,
      role: 'owner',
      accessLevel: 'read_write',
      status: 'active',
    );

    // Create default entitlements
    await _entitlementService.createDefaultEntitlement(spaceId);

    _log.info('Space created: ${space['name']} ($spaceId) by $userId');

    return {...space, 'membership': membership};
  }

  /// Lists all spaces the user is a member of.
  Future<List<Map<String, dynamic>>> listMySpaces(String userId) async {
    return _repo.listByUserId(userId);
  }

  /// Gets a single space by ID (caller must be authorized via middleware).
  Future<Map<String, dynamic>> getSpace(String spaceId, String userId) async {
    final space = await _repo.findById(spaceId);
    if (space == null || space['deleted_at'] != null) {
      throw const SpaceException(
        'Space not found',
        code: 'SPACE_NOT_FOUND',
        statusCode: 404,
      );
    }

    final membership = await _repo.getMember(spaceId, userId);
    final memberCount = await _repo.countActiveMembers(spaceId);

    return {...space, 'membership': membership, 'member_count': memberCount};
  }

  /// Updates a space's details (admin or owner only).
  Future<Map<String, dynamic>> updateSpace({
    required String spaceId,
    required String userId,
    required String userRole,
    String? name,
    String? description,
    String? iconUrl,
    String? type,
  }) async {
    // Check permission
    if (userRole != 'owner' && userRole != 'admin') {
      throw const SpaceException(
        'Only owners and admins can update space settings',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Validate type if provided
    if (type != null && !_validTypes.contains(type)) {
      throw SpaceException(
        'Invalid space type. Must be one of: ${_validTypes.join(", ")}',
        code: 'INVALID_TYPE',
        statusCode: 422,
      );
    }

    // Validate name if provided
    if (name != null) {
      if (name.trim().isEmpty || name.trim().length < 2) {
        throw const SpaceException(
          'Space name must be at least 2 characters',
          code: 'INVALID_NAME',
          statusCode: 422,
        );
      }
    }

    final updated = await _repo.updateSpace(
      spaceId,
      name: name?.trim(),
      description: description?.trim(),
      iconUrl: iconUrl,
      type: type,
    );

    if (updated == null) {
      throw const SpaceException(
        'Space not found',
        code: 'SPACE_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Space updated: $spaceId by $userId');
    return updated;
  }

  /// Deletes a space (owner only, schedules for permanent deletion).
  Future<void> deleteSpace({
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    if (userRole != 'owner') {
      throw const SpaceException(
        'Only the space owner can delete a space',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteSpace(spaceId);
    _log.info('Space $spaceId scheduled for deletion by $userId');
  }

  // ---------------------------------------------------------------------------
  // Invites & Joining
  // ---------------------------------------------------------------------------

  /// Creates an invite code for a space.
  Future<Map<String, dynamic>> createInvite({
    required String spaceId,
    required String userId,
    required String userRole,
    int? maxUses,
    Duration? expiresIn,
  }) async {
    // Check permission
    if (userRole != 'owner' && userRole != 'admin') {
      throw const SpaceException(
        'Only owners and admins can create invites',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Check member limit
    final memberQuota = await _entitlementService.checkMemberLimit(spaceId);
    if (!memberQuota.allowed) {
      throw SpaceException(
        memberQuota.message ?? 'Member limit reached',
        code: 'MEMBER_LIMIT_REACHED',
        statusCode: 403,
      );
    }

    final code = PasswordUtils.generateInviteCode();
    final expiresAt = expiresIn != null
        ? DateTime.now().toUtc().add(expiresIn)
        : DateTime.now().toUtc().add(const Duration(days: 7)); // Default 7 days

    final invite = await _repo.createInvite(
      id: _uuid.v4(),
      spaceId: spaceId,
      code: code,
      createdBy: userId,
      maxUses: maxUses,
      expiresAt: expiresAt,
    );

    _log.info('Invite created for space $spaceId: $code');
    return invite;
  }

  /// Joins a space using an invite code.
  Future<Map<String, dynamic>> joinByCode({
    required String userId,
    required String code,
  }) async {
    // Find the invite
    final invite = await _repo.findInviteByCode(code.toUpperCase());
    if (invite == null) {
      throw const SpaceException(
        'Invalid or expired invite code',
        code: 'INVALID_INVITE',
        statusCode: 400,
      );
    }

    final spaceId = invite['space_id'] as String;

    // Check if space is deleted
    final space = await _repo.findById(spaceId);
    if (space == null || space['deleted_at'] != null) {
      throw const SpaceException(
        'This space no longer exists',
        code: 'SPACE_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Check member limit
    final memberQuota = await _entitlementService.checkMemberLimit(spaceId);
    if (!memberQuota.allowed) {
      throw SpaceException(
        memberQuota.message ?? 'This space has reached its member limit',
        code: 'MEMBER_LIMIT_REACHED',
        statusCode: 403,
      );
    }

    // Check if user is already a member
    final existing = await _repo.findMembership(spaceId, userId);
    if (existing != null) {
      final status = existing['status'] as String;
      if (status == 'active') {
        throw const SpaceException(
          'You are already a member of this space',
          code: 'ALREADY_MEMBER',
          statusCode: 409,
        );
      }

      // Reactivate if previously left or removed
      if (status == 'left' || status == 'removed') {
        final reactivated = await _repo.reactivateMember(spaceId, userId);
        await _repo.incrementInviteUses(invite['id'] as String);

        _log.info('User $userId rejoined space $spaceId via invite $code');

        return {'space': space, 'membership': reactivated};
      }
    }

    // Add as new member
    final membership = await _repo.addMember(
      spaceId: spaceId,
      userId: userId,
      role: 'member',
      accessLevel: 'read_write',
      status: 'active',
      invitedBy: invite['created_by'] as String?,
    );

    // Increment invite usage
    await _repo.incrementInviteUses(invite['id'] as String);

    // Notify existing members
    final members = await _repo.listMembers(spaceId);
    for (final member in members) {
      final memberId = member['user_id'] as String;
      if (memberId != userId) {
        await _notificationService.notify(
          userId: memberId,
          type: 'space.member_joined',
          title: 'New member joined',
          body: 'A new member has joined ${space['name']}',
          spaceId: spaceId,
        );
      }
    }

    _log.info('User $userId joined space $spaceId via invite $code');

    return {'space': space, 'membership': membership};
  }

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  /// Lists all active members of a space.
  Future<List<Map<String, dynamic>>> listMembers(String spaceId) async {
    return _repo.listMembers(spaceId);
  }

  /// Updates a member's role or access level.
  Future<Map<String, dynamic>> updateMemberRole({
    required String spaceId,
    required String targetUserId,
    required String actingUserId,
    required String actingRole,
    String? role,
    String? accessLevel,
  }) async {
    // Validate role
    if (role != null && !_validRoles.contains(role)) {
      throw SpaceException(
        'Invalid role. Must be one of: ${_validRoles.join(", ")}',
        code: 'INVALID_ROLE',
        statusCode: 422,
      );
    }

    // Validate access level
    if (accessLevel != null && !_validAccessLevels.contains(accessLevel)) {
      throw SpaceException(
        'Invalid access level. Must be one of: ${_validAccessLevels.join(", ")}',
        code: 'INVALID_ACCESS_LEVEL',
        statusCode: 422,
      );
    }

    // Check permission
    if (actingRole != 'owner' && actingRole != 'admin') {
      throw const SpaceException(
        'Only owners and admins can update member roles',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Cannot change own role
    if (actingUserId == targetUserId) {
      throw const SpaceException(
        'Cannot change your own role',
        code: 'SELF_ROLE_CHANGE',
        statusCode: 400,
      );
    }

    // Only owner can promote to admin/owner
    if (role == 'admin' || role == 'owner') {
      if (actingRole != 'owner') {
        throw const SpaceException(
          'Only the owner can promote members to admin or owner',
          code: 'FORBIDDEN',
          statusCode: 403,
        );
      }
    }

    // Cannot set someone as owner via this endpoint
    if (role == 'owner') {
      throw const SpaceException(
        'Use the transfer ownership endpoint to transfer ownership',
        code: 'USE_TRANSFER_OWNERSHIP',
        statusCode: 400,
      );
    }

    // Check that target exists and is active
    final targetMember = await _repo.getMember(spaceId, targetUserId);
    if (targetMember == null || targetMember['status'] != 'active') {
      throw const SpaceException(
        'Member not found',
        code: 'MEMBER_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Cannot demote the owner
    if (targetMember['role'] == 'owner') {
      throw const SpaceException(
        'Cannot change the owner\'s role. Use transfer ownership instead.',
        code: 'CANNOT_DEMOTE_OWNER',
        statusCode: 403,
      );
    }

    // Admin cannot change another admin
    if (actingRole == 'admin' && targetMember['role'] == 'admin') {
      throw const SpaceException(
        'Admins cannot modify other admins',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    final updated = await _repo.updateMember(
      spaceId,
      targetUserId,
      role: role,
      accessLevel: accessLevel,
    );

    if (updated == null) {
      throw const SpaceException(
        'Failed to update member',
        code: 'UPDATE_FAILED',
        statusCode: 500,
      );
    }

    _log.info(
      'Member $targetUserId updated in space $spaceId by $actingUserId',
    );

    return updated;
  }

  /// Removes a member from a space.
  Future<void> removeMember({
    required String spaceId,
    required String targetUserId,
    required String actingUserId,
    required String actingRole,
  }) async {
    // Check permission
    if (actingRole != 'owner' && actingRole != 'admin') {
      throw const SpaceException(
        'Only owners and admins can remove members',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Cannot remove yourself
    if (actingUserId == targetUserId) {
      throw const SpaceException(
        'Use the leave endpoint to leave a space',
        code: 'USE_LEAVE',
        statusCode: 400,
      );
    }

    // Check target
    final targetMember = await _repo.getMember(spaceId, targetUserId);
    if (targetMember == null || targetMember['status'] != 'active') {
      throw const SpaceException(
        'Member not found',
        code: 'MEMBER_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Cannot remove the owner
    if (targetMember['role'] == 'owner') {
      throw const SpaceException(
        'Cannot remove the space owner',
        code: 'CANNOT_REMOVE_OWNER',
        statusCode: 403,
      );
    }

    // Admin cannot remove another admin
    if (actingRole == 'admin' && targetMember['role'] == 'admin') {
      throw const SpaceException(
        'Admins cannot remove other admins',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Perform three-category data separation before removing:
    // 1. Space-visible data created by user → ghost records (anonymize)
    await _repo.anonymizeUserContentInSpace(spaceId, targetUserId);
    // 2. Personal references (messages, assignments, votes) → remove attribution
    await _repo.removePersonalReferencesInSpace(spaceId, targetUserId);
    // 3. Personally owned data (vault, location) → delete from space
    await _repo.deletePersonalDataInSpace(spaceId, targetUserId);

    await _repo.removeMember(spaceId, targetUserId);

    // Notify the removed user
    await _notificationService.notify(
      userId: targetUserId,
      type: 'space.removed',
      title: 'Removed from space',
      body: 'You have been removed from a space',
      spaceId: spaceId,
    );

    _log.info(
      'Member $targetUserId removed from space $spaceId by $actingUserId',
    );
  }

  /// Leaves a space voluntarily.
  Future<void> leaveSpace({
    required String spaceId,
    required String userId,
    required String userRole,
  }) async {
    // Owner cannot leave without transferring ownership
    if (userRole == 'owner') {
      throw const SpaceException(
        'The owner cannot leave the space. Transfer ownership first, '
        'or delete the space.',
        code: 'OWNER_CANNOT_LEAVE',
        statusCode: 400,
      );
    }

    // Perform three-category data separation before leaving:
    // 1. Space-visible data created by user → ghost records (anonymize)
    await _repo.anonymizeUserContentInSpace(spaceId, userId);
    // 2. Personal references (messages, assignments, votes) → remove attribution
    await _repo.removePersonalReferencesInSpace(spaceId, userId);
    // 3. Personally owned data (vault, location) → delete from space
    await _repo.deletePersonalDataInSpace(spaceId, userId);

    await _repo.leaveSpace(spaceId, userId);

    _log.info('User $userId left space $spaceId');
  }

  /// Transfers ownership to another member.
  Future<void> transferOwnership({
    required String spaceId,
    required String fromUserId,
    required String fromUserRole,
    required String toUserId,
  }) async {
    if (fromUserRole != 'owner') {
      throw const SpaceException(
        'Only the owner can transfer ownership',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    if (fromUserId == toUserId) {
      throw const SpaceException(
        'Cannot transfer ownership to yourself',
        code: 'SELF_TRANSFER',
        statusCode: 400,
      );
    }

    // Verify the target is an active member
    final targetMember = await _repo.getMember(spaceId, toUserId);
    if (targetMember == null || targetMember['status'] != 'active') {
      throw const SpaceException(
        'Target user is not an active member of this space',
        code: 'MEMBER_NOT_FOUND',
        statusCode: 404,
      );
    }

    await _repo.transferOwnership(spaceId, fromUserId, toUserId);

    // Notify the new owner
    await _notificationService.notify(
      userId: toUserId,
      type: 'space.ownership_transferred',
      title: 'You are now the owner',
      body: 'Ownership of the space has been transferred to you',
      spaceId: spaceId,
    );

    _log.info(
      'Ownership of space $spaceId transferred from $fromUserId to $toUserId',
    );
  }
}
