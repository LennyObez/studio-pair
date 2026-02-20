import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/auth_provider.dart';
import 'package:studio_pair/src/providers/location_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart' hide LocationShare;

/// Location sharing screen with map placeholder and sharing controls.
class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  @override
  void initState() {
    super.initState();
    _loadShares();
  }

  void _loadShares() {
    final spaceId = ref.read(spaceProvider).valueOrNull?.currentSpace?.id;
    if (spaceId != null) {
      ref.read(locationProvider.notifier).loadActiveShares(spaceId);
    }
  }

  /// Gets the current device position, requesting permissions as needed.
  Future<Position?> _getCurrentPosition(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('locationServicesDisabled')),
          ),
        );
      }
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.translate('locationPermissionDenied')),
            ),
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.translate('locationPermissionPermanentlyDenied'),
            ),
          ),
        );
      }
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Starts sharing with real device coordinates.
  Future<void> _startSharingWithLocation(
    String spaceId,
    int durationMinutes,
  ) async {
    final position = await _getCurrentPosition(context);
    if (position != null && mounted) {
      await ref
          .read(locationProvider.notifier)
          .startSharing(
            spaceId,
            position.latitude,
            position.longitude,
            durationMinutes,
          );
    }
  }

  /// Sends a safe ping with real device coordinates.
  Future<void> _sendSafePingWithLocation(String spaceId) async {
    final position = await _getCurrentPosition(context);
    if (position != null && mounted) {
      await ref
          .read(locationProvider.notifier)
          .sendSafePing(spaceId, position.latitude, position.longitude);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('safePingSentToMembers')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLocation = ref.watch(locationProvider);
    final spaceId =
        ref.watch(spaceProvider).valueOrNull?.currentSpace?.id ?? '';
    final theme = Theme.of(context);
    final activeShares = asyncLocation.valueOrNull?.activeShares ?? [];
    final isSharing = asyncLocation.valueOrNull?.isSharing ?? false;
    final myActiveShare = asyncLocation.valueOrNull?.myActiveShare;

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('location'),
        showBackButton: true,
      ),
      body: _buildBody(
        asyncLocation,
        theme,
        spaceId,
        activeShares,
        isSharing,
        myActiveShare,
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<LocationData> asyncLocation,
    ThemeData theme,
    String spaceId,
    List<LocationShare> activeShares,
    bool isSharing,
    LocationShare? myActiveShare,
  ) {
    if (asyncLocation.isLoading && activeShares.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (asyncLocation.hasError && activeShares.isEmpty) {
      return SpErrorWidget(
        message: asyncLocation.error is AppFailure
            ? (asyncLocation.error as AppFailure).message
            : '${asyncLocation.error}',
        onRetry: _loadShares,
      );
    }

    return Column(
      children: [
        // Map placeholder
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            color: AppColors.moduleLocation.withValues(alpha: 0.08),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 80,
                    color: AppColors.moduleLocation.withValues(alpha: 0.5),
                    semanticLabel: 'Map view placeholder',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.translate('mapView'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    activeShares.isNotEmpty
                        ? context.l10n.translateWith('activeSharesCount', [
                            '${activeShares.length}',
                          ])
                        : context.l10n.translate('locationSharingMap'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Controls
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Share duration buttons
                Text(
                  context.l10n.translate('shareLocationFor'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _DurationButton(
                        label: context.l10n.translate('minutes15'),
                        theme: theme,
                        onTap: () => _startSharingWithLocation(spaceId, 15),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DurationButton(
                        label: context.l10n.translate('minutes30'),
                        theme: theme,
                        onTap: () => _startSharingWithLocation(spaceId, 30),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DurationButton(
                        label: context.l10n.translate('hour1'),
                        theme: theme,
                        onTap: () => _startSharingWithLocation(spaceId, 60),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DurationButton(
                        label: context.l10n.translate('hours2'),
                        theme: theme,
                        onTap: () => _startSharingWithLocation(spaceId, 120),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Stop sharing button (visible when sharing)
                if (isSharing && myActiveShare != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(locationProvider.notifier)
                              .stopSharing(spaceId, myActiveShare.id);
                        },
                        icon: const Icon(Icons.stop, color: AppColors.error),
                        label: Text(context.l10n.translate('stopSharing')),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ),
                  ),

                // I'm safe button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _sendSafePingWithLocation(spaceId),
                    icon: const Icon(Icons.shield),
                    label: Text(context.l10n.translate('imSafe')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Members sharing status
                Text(
                  context.l10n.translate('members'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      // Show active shares from other members
                      ...activeShares.map((share) {
                        final currentUserId = ref.read(currentUserProvider)?.id;
                        final isMine = share.userId == currentUserId;
                        final remaining = share.expiresAt != null
                            ? share.expiresAt!
                                  .difference(DateTime.now())
                                  .inMinutes
                            : 0;

                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.success.withValues(
                                  alpha: 0.12,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.success,
                                ),
                              ),
                              title: Text(
                                isMine
                                    ? context.l10n.translate('you')
                                    : context.l10n.translate('partner'),
                              ),
                              subtitle: Text(
                                share.type == 'safe_ping'
                                    ? context.l10n.translate('safePingSent')
                                    : context.l10n.translateWith(
                                        'sharingForMinutes',
                                        ['$remaining'],
                                      ),
                              ),
                              trailing: const Icon(
                                Icons.location_on,
                                color: AppColors.success,
                                semanticLabel: 'Sharing location',
                              ),
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      }),
                      // Show "not sharing" for current user if not sharing
                      if (!isSharing)
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.grey200,
                            child: Icon(Icons.person, color: AppColors.grey500),
                          ),
                          title: Text(context.l10n.translate('you')),
                          subtitle: Text(context.l10n.translate('notSharing')),
                          trailing: const Icon(
                            Icons.location_off,
                            color: AppColors.grey500,
                            semanticLabel: 'Not sharing location',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationButton extends StatelessWidget {
  const _DurationButton({
    required this.label,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.moduleLocation),
      ),
      child: Text(label),
    );
  }
}
