import 'package:freezed_annotation/freezed_annotation.dart';

part 'charter.freezed.dart';
part 'charter.g.dart';

/// Represents a relationship charter for a space.
@freezed
abstract class Charter with _$Charter {
  const factory Charter({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'current_version') required int currentVersion,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Charter;

  factory Charter.fromJson(Map<String, dynamic> json) =>
      _$CharterFromJson(json);
}
