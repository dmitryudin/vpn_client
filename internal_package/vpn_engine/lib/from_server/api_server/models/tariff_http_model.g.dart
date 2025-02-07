// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff_http_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TariffHttpModel _$TariffHttpModelFromJson(Map json) => TariffHttpModel(
      id: (json['id'] as num?)?.toInt(),
      descryption: json['descryption'] as String?,
      days: (json['days'] as num?)?.toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      max_number_of_devices: (json['max_number_of_devices'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$TariffHttpModelToJson(TariffHttpModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'descryption': instance.descryption,
      'days': instance.days,
      'cost': instance.cost,
      'max_number_of_devices': instance.max_number_of_devices,
    };
