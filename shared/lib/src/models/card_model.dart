import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/card_provider.dart';
import '../enums/card_type.dart';

part 'card_model.g.dart';

/// Represents a payment or loyalty card stored in a space.
@JsonSerializable()
class CardModel extends Equatable {
  const CardModel({
    required this.id,
    required this.spaceId,
    required this.createdBy,
    required this.cardType,
    required this.displayName,
    this.provider,
    this.lastFour,
    this.expiryMonth,
    this.expiryYear,
    this.cardColor,
    this.loyaltyStoreName,
    this.loyaltyStoreLogoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'space_id')
  final String spaceId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'card_type')
  final CardType cardType;

  @JsonKey(name: 'display_name')
  final String displayName;

  @JsonKey(name: 'provider')
  final CardProvider? provider;

  @JsonKey(name: 'last_four')
  final String? lastFour;

  @JsonKey(name: 'expiry_month')
  final int? expiryMonth;

  @JsonKey(name: 'expiry_year')
  final int? expiryYear;

  @JsonKey(name: 'card_color')
  final String? cardColor;

  @JsonKey(name: 'loyalty_store_name')
  final String? loyaltyStoreName;

  @JsonKey(name: 'loyalty_store_logo_url')
  final String? loyaltyStoreLogoUrl;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    spaceId,
    createdBy,
    cardType,
    displayName,
    provider,
    lastFour,
    expiryMonth,
    expiryYear,
    cardColor,
    loyaltyStoreName,
    loyaltyStoreLogoUrl,
    createdAt,
    updatedAt,
  ];
}
