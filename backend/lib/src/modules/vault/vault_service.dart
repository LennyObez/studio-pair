import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../spaces/spaces_repository.dart';
import 'vault_repository.dart';

/// Custom exception for vault-related errors.
class VaultException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const VaultException(
    this.message, {
    this.code = 'VAULT_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'VaultException($code): $message';
}

/// Service containing all vault-related business logic.
class VaultService {
  final VaultRepository _repo;
  final SpacesRepository _spacesRepo;
  final NotificationService _notificationService;
  final Logger _log = Logger('VaultService');
  final Uuid _uuid = const Uuid();

  VaultService(this._repo, this._spacesRepo, this._notificationService);

  // ---------------------------------------------------------------------------
  // Entry CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new vault entry.
  ///
  /// Validates inputs (domain required), stores the encrypted blob as-is
  /// (the server never decrypts), and returns the created entry.
  Future<Map<String, dynamic>> createEntry({
    required String spaceId,
    required String userId,
    required String domain,
    String? faviconUrl,
    String? label,
    required String encryptedBlob,
  }) async {
    // Validate domain
    if (domain.trim().isEmpty) {
      throw const VaultException(
        'Domain is required',
        code: 'INVALID_DOMAIN',
        statusCode: 422,
      );
    }

    if (domain.trim().length > 253) {
      throw const VaultException(
        'Domain must be at most 253 characters',
        code: 'INVALID_DOMAIN',
        statusCode: 422,
      );
    }

    // Validate encrypted blob is present
    if (encryptedBlob.isEmpty) {
      throw const VaultException(
        'Encrypted blob is required',
        code: 'INVALID_ENCRYPTED_BLOB',
        statusCode: 422,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final entryId = _uuid.v4();

    final entry = await _repo.createEntry(
      id: entryId,
      spaceId: spaceId,
      createdBy: userId,
      domain: domain.trim().toLowerCase(),
      faviconUrl: faviconUrl?.trim(),
      label: label?.trim(),
      encryptedBlob: encryptedBlob,
    );

    _log.info(
      'Vault entry created: ${entry['domain']} ($entryId) in space $spaceId',
    );

    return entry;
  }

  /// Gets a single vault entry by ID.
  ///
  /// Verifies the requesting user is the creator or a shared-with user,
  /// and returns the encrypted blob (client decrypts).
  Future<Map<String, dynamic>> getEntry({
    required String entryId,
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    final entry = await _repo.getEntryById(entryId);
    if (entry == null) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the entry belongs to the requested space
    if (entry['space_id'] != spaceId) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify access: creator or shared-with
    final isCreator = entry['created_by'] == userId;
    final shares = entry['shares'] as List<Map<String, dynamic>>? ?? [];
    final isSharedWith = shares.any((s) => s['shared_with_user_id'] == userId);

    if (!isCreator && !isSharedWith) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    return entry;
  }

  /// Gets vault entries for a user in a space (own + shared), with optional
  /// domain filtering and search, supporting cursor-based pagination.
  Future<Map<String, dynamic>> getEntries({
    required String spaceId,
    required String userId,
    String? domain,
    String? search,
    String? cursor,
    int limit = 25,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Clamp limit
    final clampedLimit = limit.clamp(1, 100);

    final entries = await _repo.getEntries(
      spaceId,
      userId,
      domain: domain,
      search: search,
      cursor: cursor,
      limit: clampedLimit,
    );

    // Determine if there are more results
    final hasMore = entries.length > clampedLimit;
    final data = hasMore ? entries.sublist(0, clampedLimit) : entries;
    final nextCursor = hasMore ? data.last['created_at'] as String : null;

    return {'data': data, 'cursor': nextCursor, 'has_more': hasMore};
  }

  /// Updates an existing vault entry.
  ///
  /// Only the entry creator can update it.
  Future<Map<String, dynamic>> updateEntry({
    required String entryId,
    required String spaceId,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    // Fetch the existing entry
    final existing = await _repo.getEntryById(entryId);
    if (existing == null) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the entry belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify creator only
    if (existing['created_by'] != userId) {
      throw const VaultException(
        'Only the entry creator can update this entry',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Validate domain if provided
    if (updates.containsKey('domain')) {
      final dom = updates['domain'] as String?;
      if (dom == null || dom.trim().isEmpty) {
        throw const VaultException(
          'Domain cannot be empty',
          code: 'INVALID_DOMAIN',
          statusCode: 422,
        );
      }
      updates['domain'] = dom.trim().toLowerCase();
    }

    final updated = await _repo.updateEntry(entryId, updates);
    if (updated == null) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    _log.info('Vault entry updated: $entryId in space $spaceId by $userId');

    return updated;
  }

  /// Deletes a vault entry (soft delete).
  ///
  /// Only the entry creator can delete it (cannot delete entries shared by
  /// others).
  Future<void> deleteEntry({
    required String entryId,
    required String spaceId,
    required String userId,
  }) async {
    // Fetch the existing entry
    final existing = await _repo.getEntryById(entryId);
    if (existing == null) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the entry belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify creator only
    if (existing['created_by'] != userId) {
      throw const VaultException(
        'Only the entry creator can delete this entry',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.softDeleteEntry(entryId);

    _log.info('Vault entry deleted: $entryId in space $spaceId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Sharing
  // ---------------------------------------------------------------------------

  /// Shares a vault entry with another user, accepting a re-encrypted
  /// symmetric key for end-to-end encryption.
  ///
  /// Verifies the requesting user is the creator and the recipient is a
  /// space member.
  Future<Map<String, dynamic>> shareEntry({
    required String entryId,
    required String spaceId,
    required String userId,
    required String sharedWithUserId,
    required String encryptedSymmetricKey,
  }) async {
    // Fetch the existing entry
    final existing = await _repo.getEntryById(entryId);
    if (existing == null) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the entry belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify creator
    if (existing['created_by'] != userId) {
      throw const VaultException(
        'Only the entry creator can share this entry',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Cannot share with self
    if (sharedWithUserId == userId) {
      throw const VaultException(
        'Cannot share an entry with yourself',
        code: 'INVALID_SHARE',
        statusCode: 422,
      );
    }

    // Validate encrypted symmetric key
    if (encryptedSymmetricKey.isEmpty) {
      throw const VaultException(
        'Encrypted symmetric key is required for sharing',
        code: 'INVALID_SYMMETRIC_KEY',
        statusCode: 422,
      );
    }

    // Verify recipient is a space member
    final recipientMembership = await _spacesRepo.getMember(
      spaceId,
      sharedWithUserId,
    );
    if (recipientMembership == null ||
        recipientMembership['status'] != 'active') {
      throw const VaultException(
        'Recipient must be an active member of the space',
        code: 'INVALID_RECIPIENT',
        statusCode: 422,
      );
    }

    final share = await _repo.shareEntry(
      id: _uuid.v4(),
      entryId: entryId,
      sharedWithUserId: sharedWithUserId,
      encryptedSymmetricKey: encryptedSymmetricKey,
      sharedByUserId: userId,
    );

    // Notify the recipient
    await _notificationService.notify(
      userId: sharedWithUserId,
      type: 'vault.shared',
      title: 'Vault entry shared with you',
      body:
          'A vault entry for "${existing['domain']}" has been shared with you',
      spaceId: spaceId,
      data: {'entry_id': entryId, 'domain': existing['domain']},
    );

    _log.info('Vault entry shared: $entryId with $sharedWithUserId by $userId');

    return share;
  }

  /// Removes a vault entry share for a user.
  ///
  /// Verifies the requesting user is the creator.
  Future<void> unshareEntry({
    required String entryId,
    required String spaceId,
    required String userId,
    required String unshareUserId,
  }) async {
    // Fetch the existing entry
    final existing = await _repo.getEntryById(entryId);
    if (existing == null) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify the entry belongs to the requested space
    if (existing['space_id'] != spaceId) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify creator
    if (existing['created_by'] != userId) {
      throw const VaultException(
        'Only the entry creator can manage shares for this entry',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    await _repo.unshareEntry(entryId, unshareUserId);

    _log.info('Vault entry unshared: $entryId from $unshareUserId by $userId');
  }

  // ---------------------------------------------------------------------------
  // Domain Groups
  // ---------------------------------------------------------------------------

  /// Gets domain groupings for a user in a space.
  Future<List<Map<String, dynamic>>> getDomainGroups({
    required String spaceId,
    required String userId,
  }) async {
    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    return _repo.getDomainGroups(spaceId, userId);
  }

  // ---------------------------------------------------------------------------
  // Reveal (Sensitive Access)
  // ---------------------------------------------------------------------------

  /// Reveals a vault entry's encrypted blob, requiring a sensitive access
  /// token.
  ///
  /// Verifies access (creator or shared-with), validates the sensitive access
  /// token, logs an audit entry, and returns the encrypted blob (client
  /// decrypts).
  Future<Map<String, dynamic>> revealEntry({
    required String entryId,
    required String spaceId,
    required String userId,
    required String sensitiveAccessToken,
  }) async {
    // Validate sensitive access token
    if (sensitiveAccessToken.isEmpty) {
      throw const VaultException(
        'Sensitive access token is required to reveal vault entry data',
        code: 'SENSITIVE_ACCESS_REQUIRED',
        statusCode: 401,
      );
    }

    // Verify space membership
    await _verifySpaceMembership(spaceId, userId);

    // Fetch the entry
    final entry = await _repo.getEntryById(entryId);
    if (entry == null) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (entry['space_id'] != spaceId) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Verify access: creator or shared-with
    final isCreator = entry['created_by'] == userId;
    final shares = entry['shares'] as List<Map<String, dynamic>>? ?? [];
    final isSharedWith = shares.any((s) => s['shared_with_user_id'] == userId);

    if (!isCreator && !isSharedWith) {
      throw const VaultException(
        'Vault entry not found',
        code: 'ENTRY_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Log audit entry for sensitive access
    _log.info(
      'AUDIT: Vault entry revealed: $entryId by $userId in space $spaceId',
    );

    return entry;
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Verifies that a user is an active member of a space.
  Future<Map<String, dynamic>> _verifySpaceMembership(
    String spaceId,
    String userId,
  ) async {
    final membership = await _spacesRepo.getMember(spaceId, userId);
    if (membership == null || membership['status'] != 'active') {
      throw const VaultException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
