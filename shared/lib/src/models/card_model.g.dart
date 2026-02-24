// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardModel _$CardModelFromJson(Map<String, dynamic> json) => _CardModel(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  createdBy: json['created_by'] as String,
  cardType: $enumDecode(_$CardTypeEnumMap, json['card_type']),
  displayName: json['display_name'] as String,
  provider: $enumDecodeNullable(_$CardProviderEnumMap, json['provider']),
  lastFour: json['last_four'] as String?,
  expiryMonth: (json['expiry_month'] as num?)?.toInt(),
  expiryYear: (json['expiry_year'] as num?)?.toInt(),
  cardColor: json['card_color'] as String?,
  loyaltyStoreName: json['loyalty_store_name'] as String?,
  loyaltyStoreLogoUrl: json['loyalty_store_logo_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CardModelToJson(_CardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'space_id': instance.spaceId,
      'created_by': instance.createdBy,
      'card_type': _$CardTypeEnumMap[instance.cardType]!,
      'display_name': instance.displayName,
      'provider': _$CardProviderEnumMap[instance.provider],
      'last_four': instance.lastFour,
      'expiry_month': instance.expiryMonth,
      'expiry_year': instance.expiryYear,
      'card_color': instance.cardColor,
      'loyalty_store_name': instance.loyaltyStoreName,
      'loyalty_store_logo_url': instance.loyaltyStoreLogoUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$CardTypeEnumMap = {
  CardType.debit: 'debit',
  CardType.credit: 'credit',
  CardType.loyalty: 'loyalty',
};

const _$CardProviderEnumMap = {
  CardProvider.visa: 'visa',
  CardProvider.mastercard: 'mastercard',
  CardProvider.amex: 'amex',
  CardProvider.maestro: 'maestro',
  CardProvider.discover: 'discover',
  CardProvider.dinersClub: 'diners_club',
  CardProvider.jcb: 'jcb',
  CardProvider.unionPay: 'union_pay',
  CardProvider.unknown: 'unknown',
};
