import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory.freezed.dart';
part 'memory.g.dart';

/// Represents a shared memory within a space.
@freezed
abstract class Memory with _$Memory {
  const factory Memory({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'created_by') required String createdBy,
    required String title,
    DateTime? date,
    String? location,
    @JsonKey(name: 'location_lat') double? locationLat,
    @JsonKey(name: 'location_lng') double? locationLng,
    String? description,
    @JsonKey(name: 'linked_activity_id') String? linkedActivityId,
    @JsonKey(name: 'is_milestone') required bool isMilestone,
    @JsonKey(name: 'milestone_type') String? milestoneType,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Memory;

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);
}
