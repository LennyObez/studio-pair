import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/files_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/services/database/app_database.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';
import 'package:studio_pair_shared/studio_pair_shared.dart';

/// File browser screen with folder navigation and grid/list toggle.
class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  bool _isGridView = true;

  void _refreshFiles() {
    ref.invalidate(filesProvider);
    ref.invalidate(foldersProvider);
  }

  void _navigateToFolder(String? folderId) {
    ref.read(currentFolderIdProvider.notifier).state = folderId;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month]} ${date.day}';
  }

  IconData _iconForMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return Icons.table_chart;
    }
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description;
    }
    if (mimeType.startsWith('video/')) return Icons.videocam;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    return Icons.insert_drive_file;
  }

  void _showUploadOptions(BuildContext context, String spaceId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.translate('pickFromGallery')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadImage(spaceId, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.l10n.translate('takePhoto')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadImage(spaceId, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.create_new_folder),
                title: Text(context.l10n.translate('createFolder')),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showCreateFolderDialog(context, spaceId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(String spaceId, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.translateWith('uploadingFile', [pickedFile.name]),
        ),
      ),
    );

    final folderId = ref.read(currentFolderIdProvider);
    final success = await ref
        .read(filesProvider.notifier)
        .uploadFile(
          spaceId,
          pickedFile.path,
          folderId: folderId,
          filename: pickedFile.name,
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pickedFile.name} uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.translate('uploadFailed'))),
      );
    }
  }

  void _showCreateFolderDialog(BuildContext context, String spaceId) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.l10n.translate('createFolder')),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Folder name',
              hintText: 'Enter folder name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                final parentFolderId = ref.read(currentFolderIdProvider);
                final success = await ref
                    .read(foldersProvider.notifier)
                    .createFolder(
                      spaceId,
                      name,
                      parentFolderId: parentFolderId,
                    );
                if (success && ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(context.l10n.translate('create')),
            ),
          ],
        );
      },
    );
  }

  void _showFileActions(BuildContext context, String spaceId, CachedFile file) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(context.l10n.translate('details')),
                subtitle: Text(
                  '${_formatFileSize(file.sizeBytes)} - ${file.mimeType}',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  context.l10n.translate('delete'),
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dlgCtx) => AlertDialog(
                      title: Text(context.l10n.translate('deleteFile')),
                      content: Text(
                        context.l10n.translateWith('deleteFileConfirm', [
                          file.filename,
                        ]),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dlgCtx).pop(false),
                          child: Text(context.l10n.translate('cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dlgCtx).pop(true),
                          child: Text(
                            context.l10n.translate('delete'),
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await ref
                        .read(filesProvider.notifier)
                        .deleteFile(spaceId, file.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFolderActions(
    BuildContext context,
    String spaceId,
    Map<String, dynamic> folder,
  ) {
    final folderName = folder['name'] as String? ?? '';
    final folderId = folder['id'] as String? ?? '';
    final fileCount = folder['file_count'] as int? ?? 0;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(folderName),
                subtitle: Text('$fileCount files'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  context.l10n.translate('deleteFolder'),
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dlgCtx) => AlertDialog(
                      title: Text(context.l10n.translate('deleteFolder')),
                      content: Text(
                        context.l10n.translateWith('deleteFolderConfirm', [
                          folderName,
                        ]),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dlgCtx).pop(false),
                          child: Text(context.l10n.translate('cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dlgCtx).pop(true),
                          child: Text(
                            context.l10n.translate('delete'),
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await ref
                        .read(foldersProvider.notifier)
                        .deleteFolder(spaceId, folderId);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncFiles = ref.watch(filesProvider);
    final asyncFolders = ref.watch(foldersProvider);
    final spaceId =
        ref.watch(spaceProvider).valueOrNull?.currentSpace?.id ?? '';
    final currentFolderId = ref.watch(currentFolderIdProvider);
    final theme = Theme.of(context);
    final files = asyncFiles.valueOrNull ?? [];
    final folders = asyncFolders.valueOrNull ?? [];

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('files'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            tooltip: _isGridView
                ? context.l10n.translate('list')
                : context.l10n.translate('grid'),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb (simplified: Home > current folder)
          _buildBreadcrumb(currentFolderId, theme),
          const Divider(height: 1),

          // File list/grid
          Expanded(
            child: _buildBody(
              asyncFiles,
              asyncFolders,
              theme,
              spaceId,
              files,
              folders,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadOptions(context, spaceId),
        tooltip: context.l10n.translate('upload'),
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildBreadcrumb(String? currentFolderId, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              _navigateToFolder(null);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Home',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: currentFolderId == null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (currentFolderId != null) ...[
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            Text(
              '...',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<CachedFile>> asyncFiles,
    AsyncValue<List<Map<String, dynamic>>> asyncFolders,
    ThemeData theme,
    String spaceId,
    List<CachedFile> files,
    List<Map<String, dynamic>> folders,
  ) {
    if (asyncFiles.isLoading && asyncFolders.isLoading) {
      return const Center(child: SpLoading());
    }

    if (asyncFiles.hasError) {
      return SpErrorWidget(
        message: asyncFiles.error is AppFailure
            ? (asyncFiles.error as AppFailure).message
            : '${asyncFiles.error}',
        onRetry: _refreshFiles,
      );
    }

    if (asyncFolders.hasError) {
      return SpErrorWidget(
        message: asyncFolders.error is AppFailure
            ? (asyncFolders.error as AppFailure).message
            : '${asyncFolders.error}',
        onRetry: _refreshFiles,
      );
    }

    if (folders.isEmpty && files.isEmpty) {
      return SpEmptyState(
        icon: Icons.folder_open,
        title: context.l10n.translate('noFiles'),
        description: context.l10n.translate('uploadFilesDescription'),
      );
    }

    if (_isGridView) {
      return _buildGridView(folders, files, theme, spaceId);
    }
    return _buildListView(folders, files, theme, spaceId);
  }

  Widget _buildGridView(
    List<Map<String, dynamic>> folders,
    List<CachedFile> files,
    ThemeData theme,
    String spaceId,
  ) {
    final itemCount = folders.length + files.length;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < folders.length) {
          final folder = folders[index];
          final folderName = folder['name'] as String? ?? '';
          final folderId = folder['id'] as String? ?? '';
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              onTap: () {
                _navigateToFolder(folderId);
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder,
                      size: 40,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      folderName,
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final file = files[index - folders.length];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            onTap: () => _showFileActions(context, spaceId, file),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _iconForMimeType(file.mimeType),
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    file.filename,
                    style: theme.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(
    List<Map<String, dynamic>> folders,
    List<CachedFile> files,
    ThemeData theme,
    String spaceId,
  ) {
    final itemCount = folders.length + files.length;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index < folders.length) {
          final folder = folders[index];
          final folderName = folder['name'] as String? ?? '';
          final folderId = folder['id'] as String? ?? '';
          final fileCount = folder['file_count'] as int? ?? 0;
          return ListTile(
            leading: const Icon(Icons.folder, color: AppColors.warning),
            title: Text(folderName, style: theme.textTheme.bodyMedium),
            subtitle: Text(
              '$fileCount files',
              style: theme.textTheme.labelSmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Folder options',
              onPressed: () => _showFolderActions(context, spaceId, folder),
            ),
            onTap: () {
              _navigateToFolder(folderId);
            },
          );
        }

        final file = files[index - folders.length];
        return ListTile(
          leading: Icon(
            _iconForMimeType(file.mimeType),
            color: theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(file.filename, style: theme.textTheme.bodyMedium),
          subtitle: Text(
            '${_formatFileSize(file.sizeBytes)} - ${_formatDate(file.createdAt)}',
            style: theme.textTheme.labelSmall,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'File options',
            onPressed: () => _showFileActions(context, spaceId, file),
          ),
          onTap: () => _showFileActions(context, spaceId, file),
        );
      },
    );
  }
}
