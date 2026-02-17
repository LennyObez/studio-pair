import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/file_scan_status.dart';

part 'file_model.freezed.dart';
part 'file_model.g.dart';

/// Represents a file stored within a space.
@freezed
abstract class FileModel with _$FileModel {
  const factory FileModel({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'folder_id') String? folderId,
    @JsonKey(name: 'uploaded_by') required String uploadedBy,
    required String filename,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    @JsonKey(name: 'storage_key') required String storageKey,
    @JsonKey(name: 'scan_status') required FileScanStatus scanStatus,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FileModel;

  factory FileModel.fromJson(Map<String, dynamic> json) =>
      _$FileModelFromJson(json);
}
