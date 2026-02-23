import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grocery_list.g.dart';

/// Represents a grocery list within a space.
@JsonSerializable()
class GroceryList extends Equatable {
  const GroceryList({
    required this.id,
    required this.spaceId,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryList.fromJson(Map<String, dynamic> json) =>
      _$GroceryListFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$GroceryListToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    name,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
