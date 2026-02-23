import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/services/api/spaces_api.dart';

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

/// Space state.
class SpaceState {
  const SpaceState({
    this.currentSpace,
    this.spaces = const [],
    this.members = const [],
    this.isLoading = false,
    this.error,
  });

  final Space? currentSpace;
  final List<Space> spaces;
  final List<SpaceMember> members;
  final bool isLoading;
  final String? error;

  SpaceState copyWith({
    Space? currentSpace,
    List<Space>? spaces,
    List<SpaceMember>? members,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearCurrentSpace = false,
  }) {
    return SpaceState(
      currentSpace: clearCurrentSpace
          ? null
          : (currentSpace ?? this.currentSpace),
      spaces: spaces ?? this.spaces,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Space state notifier.
class SpaceNotifier extends StateNotifier<SpaceState> {
  SpaceNotifier(this._api) : super(const SpaceState());

  final SpacesApi _api;

  /// Load spaces for the current user.
  Future<void> loadSpaces() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.listMySpaces();
      final jsonList = parseList(response.data);
      final spaces = jsonList.map(Space.fromJson).toList();

      state = state.copyWith(
        spaces: spaces,
        currentSpace: spaces.isNotEmpty ? spaces.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  /// Switch to a different space.
  void switchSpace(String spaceId) {
    final space = state.spaces.firstWhere(
      (s) => s.id == spaceId,
      orElse: () => state.spaces.first,
    );
    state = state.copyWith(currentSpace: space);
  }

  /// Create a new space and set it as the current space.
  Future<bool> createSpace({
    required String name,
    required String type,
    String? description,
    List<String>? enabledModules,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.createSpace(
        name: name,
        type: type,
        description: description,
        enabledModules: enabledModules,
      );
      final data = response.data as Map<String, dynamic>;
      final space = Space.fromJson(data);

      state = state.copyWith(
        spaces: [...state.spaces, space],
        currentSpace: space,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Join an existing space using an invite code.
  Future<bool> joinSpace(String inviteCode) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.join(inviteCode: inviteCode);
      final data = response.data as Map<String, dynamic>;
      final space = Space.fromJson(data);

      state = state.copyWith(
        spaces: [...state.spaces, space],
        currentSpace: space,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      return false;
    }
  }

  /// Invite a member to the current space by email.
  Future<bool> inviteMember(String email) async {
    if (state.currentSpace == null) return false;

    try {
      await _api.invite(state.currentSpace!.id, email: email);
      return true;
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
      return false;
    }
  }

  /// Load members of the current space.
  Future<void> loadMembers() async {
    if (state.currentSpace == null) return;

    try {
      final response = await _api.listMembers(state.currentSpace!.id);
      final jsonList = parseList(response.data);
      final members = jsonList.map(SpaceMember.fromJson).toList();

      state = state.copyWith(members: members);
    } catch (e) {
      state = state.copyWith(error: extractErrorMessage(e));
    }
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
      state = state.copyWith(
        spaces: [devSpace],
        currentSpace: devSpace,
        members: [devMember, partnerMember],
        isLoading: false,
      );
      return true;
    }());
  }
}

/// Space state provider.
final spaceProvider = StateNotifierProvider<SpaceNotifier, SpaceState>((ref) {
  return SpaceNotifier(ref.watch(spacesApiProvider));
});

/// Convenience provider for the current space.
final currentSpaceProvider = Provider<Space?>((ref) {
  return ref.watch(spaceProvider).currentSpace;
});

/// Convenience provider for space members.
final spaceMembersProvider = Provider<List<SpaceMember>>((ref) {
  return ref.watch(spaceProvider).members;
});
