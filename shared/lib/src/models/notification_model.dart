import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/notification_channel.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Represents a notification sent to a user.
@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'space_id') String? spaceId,
    required String type,
    required String title,
    required String body,
    @JsonKey(name: 'source_module') String? sourceModule,
    @JsonKey(name: 'source_entity_id') String? sourceEntityId,
    required NotificationChannel channel,
    @JsonKey(name: 'is_read') required bool isRead,
    @JsonKey(name: 'read_at') DateTime? readAt,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
