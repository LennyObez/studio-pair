import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../services/notification_service.dart';
import '../spaces/spaces_repository.dart';
import 'charter_repository.dart';

/// Custom exception for charter-related errors.
class CharterException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const CharterException(
    this.message, {
    this.code = 'CHARTER_ERROR',
    this.statusCode = 400,
  });

  @override
  String toString() => 'CharterException($code): $message';
}

/// Service containing all charter-related business logic.
class CharterService {
  final CharterRepository _repo;
  final SpacesRepository _spacesRepo;
  final NotificationService _notificationService;
  final Logger _log = Logger('CharterService');
  final Uuid _uuid = const Uuid();

  CharterService(this._repo, this._spacesRepo, this._notificationService);

  // ---------------------------------------------------------------------------
  // Charter
  // ---------------------------------------------------------------------------

  /// Gets the charter for a space, including the current version.
  ///
  /// Creates the charter if it does not exist yet.
  Future<Map<String, dynamic>> getCharter({
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Ensure charter exists
    await _repo.getOrCreateCharter(spaceId);

    final charter = await _repo.getCharter(spaceId);
    if (charter == null) {
      throw const CharterException(
        'Charter not found',
        code: 'CHARTER_NOT_FOUND',
        statusCode: 404,
      );
    }

    return charter;
  }

  // ---------------------------------------------------------------------------
  // Versions
  // ---------------------------------------------------------------------------

  /// Creates a new version of the charter.
  ///
  /// Validates content is not empty, creates the version, and notifies
  /// all space members to review.
  Future<Map<String, dynamic>> createVersion({
    required String spaceId,
    required String userId,
    required String content,
    String? changeSummary,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Validate content
    if (content.trim().isEmpty) {
      throw const CharterException(
        'Charter content is required',
        code: 'INVALID_CONTENT',
        statusCode: 422,
      );
    }

    // Ensure charter exists
    final charter = await _repo.getOrCreateCharter(spaceId);
    final charterId = charter['id'] as String;

    // Create the new version
    final version = await _repo.createVersion(
      id: _uuid.v4(),
      charterId: charterId,
      content: content.trim(),
      editedBy: userId,
      changeSummary: changeSummary?.trim(),
    );

    // Notify all space members to review the new version
    final members = await _spacesRepo.listMembers(spaceId);
    for (final member in members) {
      final memberId = member['user_id'] as String;
      if (memberId == userId) continue; // Don't notify the editor

      await _notificationService.notify(
        userId: memberId,
        type: 'charter.new_version',
        title: 'Charter updated',
        body:
            'A new version of the relationship charter has been published. Please review and acknowledge.',
        spaceId: spaceId,
        data: {
          'charter_id': charterId,
          'version_id': version['id'],
          'version_number': version['version_number'],
        },
      );
    }

    _log.info(
      'Charter version ${version['version_number']} created for space $spaceId by $userId',
    );

    return version;
  }

  /// Gets the version history for a space's charter.
  Future<List<Map<String, dynamic>>> getVersionHistory({
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final charter = await _repo.getCharter(spaceId);
    if (charter == null) {
      return [];
    }

    final charterId = charter['id'] as String;
    return _repo.getVersionHistory(charterId);
  }

  /// Gets a specific version by ID.
  Future<Map<String, dynamic>> getVersion({
    required String versionId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final version = await _repo.getVersion(versionId);
    if (version == null) {
      throw const CharterException(
        'Version not found',
        code: 'VERSION_NOT_FOUND',
        statusCode: 404,
      );
    }

    return version;
  }

  // ---------------------------------------------------------------------------
  // Acknowledgments
  // ---------------------------------------------------------------------------

  /// Records an acknowledgment of a charter version by the current user.
  Future<Map<String, dynamic>> acknowledgeVersion({
    required String versionId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Verify the version exists
    final version = await _repo.getVersion(versionId);
    if (version == null) {
      throw const CharterException(
        'Version not found',
        code: 'VERSION_NOT_FOUND',
        statusCode: 404,
      );
    }

    final acknowledgment = await _repo.acknowledgeVersion(
      id: _uuid.v4(),
      versionId: versionId,
      userId: userId,
    );

    _log.info('Charter version $versionId acknowledged by $userId');

    return acknowledgment;
  }

  /// Gets all acknowledgments for a charter version.
  Future<List<Map<String, dynamic>>> getAcknowledgments({
    required String versionId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    return _repo.getAcknowledgments(versionId);
  }

  /// Gets members who have not yet acknowledged a specific version.
  Future<List<Map<String, dynamic>>> getPendingAcknowledgments({
    required String versionId,
    required String spaceId,
    required String userId,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Get all active members of the space
    final members = await _spacesRepo.listMembers(spaceId);
    final memberIds = members
        .where((m) => m['status'] == 'active')
        .map((m) => m['user_id'] as String)
        .toList();

    return _repo.getPendingAcknowledgments(versionId, memberIds);
  }

  // ---------------------------------------------------------------------------
  // Amendments
  // ---------------------------------------------------------------------------

  /// Proposes a new amendment to the charter.
  ///
  /// Validates inputs, verifies space membership, and creates the amendment
  /// in 'proposed' status. Optionally starts voting immediately with a
  /// specified voting duration.
  Future<Map<String, dynamic>> proposeAmendment({
    required String spaceId,
    required String userId,
    required String title,
    required String content,
    Duration? votingDuration,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Validate title
    if (title.trim().isEmpty) {
      throw const CharterException(
        'Amendment title is required',
        code: 'INVALID_TITLE',
        statusCode: 422,
      );
    }

    if (title.trim().length > 200) {
      throw const CharterException(
        'Amendment title must be at most 200 characters',
        code: 'TITLE_TOO_LONG',
        statusCode: 422,
      );
    }

    // Validate content
    if (content.trim().isEmpty) {
      throw const CharterException(
        'Amendment content is required',
        code: 'INVALID_CONTENT',
        statusCode: 422,
      );
    }

    // Ensure charter exists
    final charter = await _repo.getOrCreateCharter(spaceId);
    final charterId = charter['id'] as String;

    // Determine voting end time if duration specified
    DateTime? votingEndsAt;
    if (votingDuration != null) {
      votingEndsAt = DateTime.now().toUtc().add(votingDuration);
    }

    final amendmentId = _uuid.v4();

    final amendment = await _repo.createAmendment(
      id: amendmentId,
      charterId: charterId,
      spaceId: spaceId,
      proposedBy: userId,
      title: title.trim(),
      content: content.trim(),
      votingEndsAt: votingEndsAt,
    );

    // If a voting duration was provided, immediately transition to voting
    if (votingDuration != null) {
      final updated = await _repo.startVoting(amendmentId, votingEndsAt!);
      if (updated != null) {
        // Notify all space members about the new amendment
        final members = await _spacesRepo.listMembers(spaceId);
        for (final member in members) {
          final memberId = member['user_id'] as String;
          if (memberId == userId) continue;

          await _notificationService.notify(
            userId: memberId,
            type: 'charter.amendment_proposed',
            title: 'New charter amendment',
            body:
                'A new amendment "${title.trim()}" has been proposed. Vote now!',
            spaceId: spaceId,
            data: {'amendment_id': amendmentId, 'charter_id': charterId},
          );
        }
        return updated;
      }
    }

    _log.info(
      'Charter amendment proposed: "$title" ($amendmentId) '
      'in space $spaceId by $userId',
    );

    return amendment;
  }

  /// Lists amendments for the charter in a space.
  ///
  /// Optionally filters by status ('proposed', 'voting', 'approved', 'rejected').
  Future<List<Map<String, dynamic>>> listAmendments({
    required String spaceId,
    required String userId,
    String? status,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    final charter = await _repo.getCharter(spaceId);
    if (charter == null) {
      return [];
    }

    final charterId = charter['id'] as String;
    final amendments = await _repo.listAmendments(charterId, status: status);

    // Attach vote tallies to each amendment
    for (final amendment in amendments) {
      final amendmentId = amendment['id'] as String;
      final tally = await _repo.getAmendmentVoteTally(amendmentId);
      amendment['votes'] = tally;
    }

    return amendments;
  }

  /// Casts a vote on an amendment.
  ///
  /// Validates the amendment is in 'voting' status, the voting window has
  /// not expired, and the vote value is valid.
  Future<Map<String, dynamic>> voteOnAmendment({
    required String amendmentId,
    required String spaceId,
    required String userId,
    required String vote,
  }) async {
    await _verifySpaceMembership(spaceId, userId);

    // Validate vote value
    if (vote != 'approve' && vote != 'reject') {
      throw const CharterException(
        'Vote must be either "approve" or "reject"',
        code: 'INVALID_VOTE',
        statusCode: 422,
      );
    }

    // Verify amendment exists and belongs to the space
    final amendment = await _repo.getAmendment(amendmentId);
    if (amendment == null || amendment['space_id'] != spaceId) {
      throw const CharterException(
        'Amendment not found',
        code: 'AMENDMENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Amendment must be in 'voting' or 'proposed' status
    final status = amendment['status'] as String;
    if (status != 'voting' && status != 'proposed') {
      throw CharterException(
        'Cannot vote on an amendment with status "$status"',
        code: 'AMENDMENT_NOT_VOTABLE',
        statusCode: 400,
      );
    }

    // Check if voting window has expired
    final votingEndsAt = amendment['voting_ends_at'] as String?;
    if (votingEndsAt != null) {
      final deadline = DateTime.parse(votingEndsAt);
      if (DateTime.now().toUtc().isAfter(deadline)) {
        throw const CharterException(
          'Voting period has ended for this amendment',
          code: 'VOTING_EXPIRED',
          statusCode: 400,
        );
      }
    }

    final voteResult = await _repo.castVote(
      id: _uuid.v4(),
      amendmentId: amendmentId,
      userId: userId,
      vote: vote,
    );

    _log.info('Vote cast on amendment $amendmentId by $userId: $vote');

    return voteResult;
  }

  /// Finalizes an amendment by tallying votes and setting the final status.
  ///
  /// The amendment is approved if approve votes are strictly greater than
  /// reject votes. Only the amendment proposer or a space admin/owner can
  /// finalize.
  Future<Map<String, dynamic>> finalizeAmendment({
    required String amendmentId,
    required String spaceId,
    required String userId,
  }) async {
    final membership = await _verifySpaceMembership(spaceId, userId);

    // Verify amendment exists and belongs to the space
    final amendment = await _repo.getAmendment(amendmentId);
    if (amendment == null || amendment['space_id'] != spaceId) {
      throw const CharterException(
        'Amendment not found',
        code: 'AMENDMENT_NOT_FOUND',
        statusCode: 404,
      );
    }

    // Only proposer or admin/owner can finalize
    final isProposer = amendment['proposed_by'] == userId;
    final role = membership['role'] as String?;
    final isAdmin = role == 'owner' || role == 'admin';

    if (!isProposer && !isAdmin) {
      throw const CharterException(
        'Only the proposer or a space admin can finalize an amendment',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    // Amendment must be in 'voting' or 'proposed' status
    final status = amendment['status'] as String;
    if (status != 'voting' && status != 'proposed') {
      throw CharterException(
        'Cannot finalize an amendment with status "$status"',
        code: 'AMENDMENT_NOT_FINALIZABLE',
        statusCode: 400,
      );
    }

    // Tally the votes
    final tally = await _repo.getAmendmentVoteTally(amendmentId);
    final approvals = tally['approve'] ?? 0;
    final rejections = tally['reject'] ?? 0;

    // Approve if approvals strictly greater than rejections
    final finalStatus = approvals > rejections ? 'approved' : 'rejected';

    final finalized = await _repo.finalizeAmendment(amendmentId, finalStatus);
    if (finalized == null) {
      throw const CharterException(
        'Failed to finalize amendment',
        code: 'FINALIZE_FAILED',
        statusCode: 500,
      );
    }

    // Attach vote tally to the response
    finalized['votes'] = tally;

    // Notify all space members about the result
    final members = await _spacesRepo.listMembers(spaceId);
    for (final member in members) {
      final memberId = member['user_id'] as String;
      await _notificationService.notify(
        userId: memberId,
        type: 'charter.amendment_finalized',
        title: 'Amendment $finalStatus',
        body: 'The amendment "${amendment['title']}" has been $finalStatus.',
        spaceId: spaceId,
        data: {
          'amendment_id': amendmentId,
          'status': finalStatus,
          'approvals': approvals,
          'rejections': rejections,
        },
      );
    }

    _log.info(
      'Amendment $amendmentId finalized as $finalStatus '
      '(approve: $approvals, reject: $rejections)',
    );

    return finalized;
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
      throw const CharterException(
        'You do not have access to this space',
        code: 'SPACE_ACCESS_DENIED',
        statusCode: 403,
      );
    }
    return membership;
  }
}
