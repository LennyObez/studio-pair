import 'package:json_annotation/json_annotation.dart';

/// Category for grocery items.
@JsonEnum(valueField: 'value')
enum GroceryCategory {
  @JsonValue('produce')
  produce('produce', 'Produce'),

  @JsonValue('dairy')
  dairy('dairy', 'Dairy'),

  @JsonValue('meat')
  meat('meat', 'Meat'),

  @JsonValue('frozen')
  frozen('frozen', 'Frozen'),

  @JsonValue('bakery')
  bakery('bakery', 'Bakery'),

  @JsonValue('beverages')
  beverages('beverages', 'Beverages'),

  @JsonValue('snacks')
  snacks('snacks', 'Snacks'),

  @JsonValue('canned_goods')
  cannedGoods('canned_goods', 'Canned Goods'),

  @JsonValue('condiments')
  condiments('condiments', 'Condiments'),

  @JsonValue('household')
  household('household', 'Household'),

  @JsonValue('personal_care')
  personalCare('personal_care', 'Personal Care'),

  @JsonValue('other')
  other('other', 'Other');

  const GroceryCategory(this.value, this.label);

  final String value;
  final String label;
}
