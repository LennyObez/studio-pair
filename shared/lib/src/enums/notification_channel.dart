import 'package:json_annotation/json_annotation.dart';

/// Channel through which a notification is delivered.
@JsonEnum(valueField: 'value')
enum NotificationChannel {
  @JsonValue('in_app')
  inApp('in_app', 'In-App'),

  @JsonValue('push')
  push('push', 'Push'),

  @JsonValue('email')
  email('email', 'Email');

  const NotificationChannel(this.value, this.label);

  final String value;
  final String label;
}
