import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/files_provider.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';

/// File browser screen with folder navigation and grid/list toggle.
class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() {
    final spaceId = ref.read(spaceProvider).currentSpace?.id;
    if (spaceId != null) {
      final folderId = ref.read(filesProvider).currentFolderId;
      ref.read(filesProvider.notifier).loadFiles(spaceId, folderId: folderId);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
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
    } catch (_) {
      return isoDate;
    }
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

    final folderId = ref.read(filesProvider).currentFolderId;
    final success = await ref
        .read(filesProvider.notifier)
        .uploadFile(
          spaceId,
          pickedFile.path,
          pickedFile.name,
          folderId: folderId,
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pickedFile.name} uploaded successfully')),
      );
      _loadFiles();
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
                final success = await ref
                    .read(filesProvider.notifier)
                    .createFolder(spaceId, name);
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

  void _showFileActions(BuildContext context, String spaceId, FileItem file) {
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
                  '${_formatFileSize(file.size)} - ${file.mimeType}',
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
    FolderItem folder,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(folder.name),
                subtitle: Text('${folder.fileCount} files'),
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
                          folder.name,
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
                        .deleteFile(spaceId, folder.id);
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
    final state = ref.watch(filesProvider);
    final spaceId = ref.watch(spaceProvider).currentSpace?.id ?? '';
    final theme = Theme.of(context);

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
          // Breadcrumb
          _buildBreadcrumb(state, theme, spaceId),
          const Divider(height: 1),

          // File list/grid
          Expanded(child: _buildBody(state, theme, spaceId)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadOptions(context, spaceId),
        tooltip: context.l10n.translate('upload'),
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildBreadcrumb(FilesState state, ThemeData theme, String spaceId) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              ref.read(filesProvider.notifier).navigateToFolder(null);
              final sid = ref.read(spaceProvider).currentSpace?.id;
              if (sid != null) {
                ref.read(filesProvider.notifier).loadFiles(sid);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Home',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ...state.breadcrumbs.map(
            (folder) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                InkWell(
                  onTap: () {
                    ref
                        .read(filesProvider.notifier)
                        .navigateToFolder(folder.id);
                    final sid = ref.read(spaceProvider).currentSpace?.id;
                    if (sid != null) {
                      ref
                          .read(filesProvider.notifier)
                          .loadFiles(sid, folderId: folder.id);
                    }
                  },
                  child: Text(
                    folder.name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(FilesState state, ThemeData theme, String spaceId) {
    if (state.isLoading) {
      return const Center(child: SpLoading());
    }

    if (state.error != null) {
      return SpErrorWidget(message: state.error!, onRetry: _loadFiles);
    }

    if (state.folders.isEmpty && state.files.isEmpty) {
      return SpEmptyState(
        icon: Icons.folder_open,
        title: context.l10n.translate('noFiles'),
        description: context.l10n.translate('uploadFilesDescription'),
      );
    }

    if (_isGridView) {
      return _buildGridView(state, theme, spaceId);
    }
    return _buildListView(state, theme, spaceId);
  }

  Widget _buildGridView(FilesState state, ThemeData theme, String spaceId) {
    final itemCount = state.folders.length + state.files.length;

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
        if (index < state.folders.length) {
          final folder = state.folders[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              onTap: () {
                ref.read(filesProvider.notifier).navigateToFolder(folder.id);
                final sid = ref.read(spaceProvider).currentSpace?.id;
                if (sid != null) {
                  ref
                      .read(filesProvider.notifier)
                      .loadFiles(sid, folderId: folder.id);
                }
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
                      folder.name,
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

        final file = state.files[index - state.folders.length];
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

  Widget _buildListView(FilesState state, ThemeData theme, String spaceId) {
    final itemCount = state.folders.length + state.files.length;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index < state.folders.length) {
          final folder = state.folders[index];
          return ListTile(
            leading: const Icon(Icons.folder, color: AppColors.warning),
            title: Text(folder.name, style: theme.textTheme.bodyMedium),
            subtitle: Text(
              '${folder.fileCount} files',
              style: theme.textTheme.labelSmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Folder options',
              onPressed: () => _showFolderActions(context, spaceId, folder),
            ),
            onTap: () {
              ref.read(filesProvider.notifier).navigateToFolder(folder.id);
              final sid = ref.read(spaceProvider).currentSpace?.id;
              if (sid != null) {
                ref
                    .read(filesProvider.notifier)
                    .loadFiles(sid, folderId: folder.id);
              }
            },
          );
        }

        final file = state.files[index - state.folders.length];
        return ListTile(
          leading: Icon(
            _iconForMimeType(file.mimeType),
            color: theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(file.filename, style: theme.textTheme.bodyMedium),
          subtitle: Text(
            '${_formatFileSize(file.size)} - ${_formatDate(file.createdAt)}',
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
