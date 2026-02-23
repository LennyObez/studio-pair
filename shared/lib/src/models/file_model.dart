import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/file_scan_status.dart';

part 'file_model.g.dart';

/// Represents a file stored within a space.
@JsonSerializable()
class FileModel extends Equatable {
  const FileModel({
    required this.id,
    required this.spaceId,
    this.folderId,
    required this.uploadedBy,
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
    required this.storageKey,
    required this.scanStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) =>
      _$FileModelFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'folder_id')
  final String? folderId;

  @JsonKey(name: 'uploaded_by')
  final String uploadedBy;

  @JsonKey(name: 'filename')
  final String filename;

  @JsonKey(name: 'mime_type')
  final String mimeType;

  @JsonKey(name: 'size_bytes')
  final int sizeBytes;

  @JsonKey(name: 'storage_key')
  final String storageKey;

  @JsonKey(name: 'scan_status')
  final FileScanStatus scanStatus;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$FileModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    folderId,
    uploadedBy,
    filename,
    mimeType,
    sizeBytes,
    storageKey,
    scanStatus,
    createdAt,
    updatedAt,
  ];
}
