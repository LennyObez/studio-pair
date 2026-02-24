import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/card_provider.dart';
import '../enums/card_type.dart';

part 'card_model.freezed.dart';
part 'card_model.g.dart';

/// Represents a payment or loyalty card stored in a space.
@freezed
abstract class CardModel with _$CardModel {
  const factory CardModel({
    required String id,
    @JsonKey(name: 'space_id') required String spaceId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'card_type') required CardType cardType,
    @JsonKey(name: 'display_name') required String displayName,
    CardProvider? provider,
    @JsonKey(name: 'last_four') String? lastFour,
    @JsonKey(name: 'expiry_month') int? expiryMonth,
    @JsonKey(name: 'expiry_year') int? expiryYear,
    @JsonKey(name: 'card_color') String? cardColor,
    @JsonKey(name: 'loyalty_store_name') String? loyaltyStoreName,
    @JsonKey(name: 'loyalty_store_logo_url') String? loyaltyStoreLogoUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CardModel;

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);
}
