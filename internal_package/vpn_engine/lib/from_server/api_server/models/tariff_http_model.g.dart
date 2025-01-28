// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff_http_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TariffHttpModel _$TariffHttpModelFromJson(Map<String, dynamic> json) =>
    TariffHttpModel(
      id: (json['id'] as num?)?.toInt(),
      descryption: json['descryption'] as String?,
      cost_in_day: (json['cost_in_day'] as num?)?.toDouble(),
      max_number_of_devices: (json['max_number_of_devices'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TariffHttpModelToJson(TariffHttpModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'descryption': instance.descryption,
      'cost_in_day': instance.cost_in_day,
      'max_number_of_devices': instance.max_number_of_devices,
    };
