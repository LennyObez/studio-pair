import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'memory.g.dart';

/// Represents a shared memory within a space.
@JsonSerializable()
class Memory extends Equatable {
  const Memory({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.title,
    this.date,
    this.location,
    this.locationLat,
    this.locationLng,
    this.description,
    this.linkedActivityId,
    required this.isMilestone,
    this.milestoneType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'date')
  final DateTime? date;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'location_lat')
  final double? locationLat;

  @JsonKey(name: 'location_lng')
  final double? locationLng;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'linked_activity_id')
  final String? linkedActivityId;

  @JsonKey(name: 'is_milestone')
  final bool isMilestone;

  @JsonKey(name: 'milestone_type')
  final String? milestoneType;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$MemoryToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    createdBy,
    title,
    date,
    location,
    locationLat,
    locationLng,
    description,
    linkedActivityId,
    isMilestone,
    milestoneType,
    createdAt,
    updatedAt,
  ];
}
