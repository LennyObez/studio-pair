import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/grocery_category.dart';

part 'grocery_item.freezed.dart';
part 'grocery_item.g.dart';

/// Represents an item within a grocery list.
@freezed
abstract class GroceryItem with _$GroceryItem {
  const factory GroceryItem({
    required String id,
    @JsonKey(name: 'list_id') required String listId,
    required String name,
    double? quantity,
    String? unit,
    required GroceryCategory category,
    String? note,
    @JsonKey(name: 'is_checked') required bool isChecked,
    @JsonKey(name: 'checked_by') String? checkedBy,
    @JsonKey(name: 'checked_at') DateTime? checkedAt,
    @JsonKey(name: 'price_cents') int? priceCents,
    @JsonKey(name: 'display_order') required int displayOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _GroceryItem;

  factory GroceryItem.fromJson(Map<String, dynamic> json) =>
      _$GroceryItemFromJson(json);
}
