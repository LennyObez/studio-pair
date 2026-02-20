import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/spaces_api.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// Space model.
class Space {
  const Space({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.avatarUrl,
    this.memberCount = 0,
    this.enabledModules = const [],
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      enabledModules: (json['enabled_modules'] as List?)?.cast<String>() ?? [],
    );
  }

  final String id;
  final String name;
  final String type;
  final String? description;
  final String? avatarUrl;
  final int memberCount;
  final List<String> enabledModules;
}

/// Space member model.
class SpaceMember {
  const SpaceMember({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.role,
    this.avatarUrl,
  });

  factory SpaceMember.fromJson(Map<String, dynamic> json) {
    return SpaceMember(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final String id;
  final String userId;
  final String displayName;
  final String role;
  final String? avatarUrl;
}

/// Composite state for space data.
class SpaceData {
  const SpaceData({
    this.currentSpace,
    this.spaces = const [],
    this.members = const [],
  });

  final Space? currentSpace;
  final List<Space> spaces;
  final List<SpaceMember> members;

  SpaceData copyWith({
    Space? currentSpace,
    List<Space>? spaces,
    List<SpaceMember>? members,
    bool clearCurrentSpace = false,
  }) {
    return SpaceData(
      currentSpace: clearCurrentSpace
          ? null
          : (currentSpace ?? this.currentSpace),
      spaces: spaces ?? this.spaces,
      members: members ?? this.members,
    );
  }
}

/// Space state notifier.
class SpaceNotifier extends AsyncNotifier<SpaceData> {
  SpacesApi get _api => ref.read(spacesApiProvider);

  @override
  Future<SpaceData> build() async {
    final api = ref.watch(spacesApiProvider);

    try {
      final response = await api.listMySpaces();
      final jsonList = parseList(response.data);
      final spaces = jsonList.map(Space.fromJson).toList();

      return SpaceData(
        spaces: spaces,
        currentSpace: spaces.isNotEmpty ? spaces.first : null,
      );
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw UnknownFailure('Failed to load spaces: $e');
    }
  }

  /// Load spaces for the current user (triggers a rebuild).
  Future<void> loadSpaces() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _api.listMySpaces();
      final jsonList = parseList(response.data);
      final spaces = jsonList.map(Space.fromJson).toList();

      return SpaceData(
        spaces: spaces,
        currentSpace: spaces.isNotEmpty ? spaces.first : null,
      );
    });
  }

  /// Switch to a different space.
  void switchSpace(String spaceId) {
    final currentData = state.valueOrNull;
    if (currentData == null) return;

    final space = currentData.spaces.firstWhere(
      (s) => s.id == spaceId,
      orElse: () => currentData.spaces.first,
    );
    state = AsyncData(currentData.copyWith(currentSpace: space));
  }

  /// Create a new space and set it as the current space.
  Future<bool> createSpace({
    required String name,
    required String type,
    String? description,
    List<String>? enabledModules,
  }) async {
    final previousData = state.valueOrNull ?? const SpaceData();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _api.createSpace(
        name: name,
        type: type,
        description: description,
        enabledModules: enabledModules,
      );
      final data = response.data as Map<String, dynamic>;
      final space = Space.fromJson(data);

      return previousData.copyWith(
        spaces: [...previousData.spaces, space],
        currentSpace: space,
      );
    });

    return !state.hasError;
  }

  /// Join an existing space using an invite code.
  Future<bool> joinSpace(String inviteCode) async {
    final previousData = state.valueOrNull ?? const SpaceData();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _api.join(inviteCode: inviteCode);
      final data = response.data as Map<String, dynamic>;
      final space = Space.fromJson(data);

      return previousData.copyWith(
        spaces: [...previousData.spaces, space],
        currentSpace: space,
      );
    });

    return !state.hasError;
  }

  /// Invite a member to the current space by email.
  Future<bool> inviteMember(String email) async {
    final currentData = state.valueOrNull;
    if (currentData?.currentSpace == null) return false;

    try {
      await _api.invite(currentData!.currentSpace!.id, email: email);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Load members of the current space.
  Future<void> loadMembers() async {
    final currentData = state.valueOrNull;
    if (currentData?.currentSpace == null) return;

    state = await AsyncValue.guard(() async {
      final response = await _api.listMembers(currentData!.currentSpace!.id);
      final jsonList = parseList(response.data);
      final members = jsonList.map(SpaceMember.fromJson).toList();

      return currentData.copyWith(members: members);
    });
  }

  /// Dev-only: set a dummy space so all screens work without a backend.
  void devSetSpace() {
    assert(() {
      const devSpace = Space(
        id: 'dev-space-00000000-0000-0000-0000-000000000001',
        name: 'Dev space',
        type: 'couple',
        description: 'Development testing space',
        memberCount: 2,
        enabledModules: [
          'activities',
          'tasks',
          'calendar',
          'messaging',
          'finances',
          'grocery',
          'reminders',
          'polls',
          'cards',
          'vault',
          'health',
          'files',
          'memories',
          'charter',
          'location',
        ],
      );
      const devMember = SpaceMember(
        id: 'dev-member-00000000-0000-0000-0000-000000000001',
        userId: 'dev-user-00000000-0000-0000-0000-000000000001',
        displayName: 'Dev User',
        role: 'owner',
      );
      const partnerMember = SpaceMember(
        id: 'dev-member-00000000-0000-0000-0000-000000000002',
        userId: 'dev-user-00000000-0000-0000-0000-000000000002',
        displayName: 'Partner',
        role: 'member',
      );
      state = const AsyncData(
        SpaceData(
          spaces: [devSpace],
          currentSpace: devSpace,
          members: [devMember, partnerMember],
        ),
      );
      return true;
    }());
  }
}

/// Space state provider.
final spaceProvider = AsyncNotifierProvider<SpaceNotifier, SpaceData>(
  SpaceNotifier.new,
);

/// Convenience provider for the current space.
final currentSpaceProvider = Provider<Space?>((ref) {
  return ref.watch(spaceProvider).valueOrNull?.currentSpace;
});

/// Convenience provider for space members.
final spaceMembersProvider = Provider<List<SpaceMember>>((ref) {
  return ref.watch(spaceProvider).valueOrNull?.members ?? [];
});
