// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeServerHttpModel _$FreeServerHttpModelFromJson(Map json) =>
    FreeServerHttpModel(
      servers: (json['servers'] as List<dynamic>?)
          ?.map((e) =>
              ServerHttpModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tariffs: (json['tariffs'] as List<dynamic>)
          .map((e) =>
              TariffHttpModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$FreeServerHttpModelToJson(
        FreeServerHttpModel instance) =>
    <String, dynamic>{
      'servers': instance.servers?.map((e) => e.toJson()).toList(),
      'tariffs': instance.tariffs.map((e) => e.toJson()).toList(),
    };
