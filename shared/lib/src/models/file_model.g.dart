// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FileModel _$FileModelFromJson(Map<String, dynamic> json) => _FileModel(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  folderId: json['folder_id'] as String?,
  uploadedBy: json['uploaded_by'] as String,
  filename: json['filename'] as String,
  mimeType: json['mime_type'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  storageKey: json['storage_key'] as String,
  scanStatus: $enumDecode(_$FileScanStatusEnumMap, json['scan_status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FileModelToJson(_FileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'space_id': instance.spaceId,
      'folder_id': instance.folderId,
      'uploaded_by': instance.uploadedBy,
      'filename': instance.filename,
      'mime_type': instance.mimeType,
      'size_bytes': instance.sizeBytes,
      'storage_key': instance.storageKey,
      'scan_status': _$FileScanStatusEnumMap[instance.scanStatus]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$FileScanStatusEnumMap = {
  FileScanStatus.pending: 'pending',
  FileScanStatus.clean: 'clean',
  FileScanStatus.infected: 'infected',
};
