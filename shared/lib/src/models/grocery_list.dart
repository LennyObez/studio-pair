import 'package:freezed_annotation/freezed_annotation.dart';

part 'grocery_list.freezed.dart';
part 'grocery_list.g.dart';

/// Represents a grocery list within a space.
@freezed
abstract class GroceryList with _$GroceryList {
  const factory GroceryList({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    required String name,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _GroceryList;

  factory GroceryList.fromJson(Map<String, dynamic> json) =>
      _$GroceryListFromJson(json);
}
