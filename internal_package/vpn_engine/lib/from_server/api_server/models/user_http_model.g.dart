// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_http_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHttpModel _$UserHttpModelFromJson(Map json) => UserHttpModel(
      balance: (json['balance'] as num?)?.toDouble(),
      is_blocked: json['is_blocked'] as bool?,
      current_tarif_id: (json['current_tarif_id'] as num?)?.toInt(),
      is_email_verified: json['is_email_verified'] as bool?,
    );

Map<String, dynamic> _$UserHttpModelToJson(UserHttpModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'is_blocked': instance.is_blocked,
      'current_tarif_id': instance.current_tarif_id,
      'is_email_verified': instance.is_email_verified,
    };
