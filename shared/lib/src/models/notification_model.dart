import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/notification_channel.dart';

part 'notification_model.g.dart';

/// Represents a notification sent to a user.
@JsonSerializable()
class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.userId,
    this.spaceId,
    required this.type,
    required this.title,
    required this.body,
    this.sourceModule,
    this.sourceEntityId,
    required this.channel,
    required this.isRead,
    this.readAt,
    this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'space_id')
  final String? spaceId;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'body')
  final String body;

  @JsonKey(name: 'source_module')
  final String? sourceModule;

  @JsonKey(name: 'source_entity_id')
  final String? sourceEntityId;

  @JsonKey(name: 'channel')
  final NotificationChannel channel;

  @JsonKey(name: 'is_read')
  final bool isRead;

  @JsonKey(name: 'read_at')
  final DateTime? readAt;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    spaceId,
    type,
    title,
    body,
    sourceModule,
    sourceEntityId,
    channel,
    isRead,
    readAt,
    metadata,
    createdAt,
  ];
}
