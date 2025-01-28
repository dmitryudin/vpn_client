// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_http_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHttpModel _$UserHttpModelFromJson(Map<String, dynamic> json) =>
    UserHttpModel(
      balance: (json['balance'] as num?)?.toDouble(),
      is_blocked: json['is_blocked'] as bool?,
    );

Map<String, dynamic> _$UserHttpModelToJson(UserHttpModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'is_blocked': instance.is_blocked,
    };
