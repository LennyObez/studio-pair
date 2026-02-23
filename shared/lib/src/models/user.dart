import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Represents a Studio Pair user account.
@JsonSerializable()
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.totpEnabled,
    required this.preferredLanguage,
    this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'totp_enabled')
  final bool totpEnabled;

  @JsonKey(name: 'preferred_language')
  final String preferredLanguage;

  @JsonKey(name: 'timezone')
  final String? timezone;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    avatarUrl,
    totpEnabled,
    preferredLanguage,
    timezone,
    createdAt,
    updatedAt,
  ];
}
