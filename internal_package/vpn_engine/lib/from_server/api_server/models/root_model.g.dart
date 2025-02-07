// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RootHttpModel _$RootHttpModelFromJson(Map json) => RootHttpModel(
      servers: (json['servers'] as List<dynamic>?)
          ?.map((e) =>
              ServerHttpModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tariffs: (json['tariffs'] as List<dynamic>)
          .map((e) =>
              TariffHttpModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      user_info: json['user_info'] == null
          ? null
          : UserHttpModel.fromJson(
              Map<String, dynamic>.from(json['user_info'] as Map)),
    );

Map<String, dynamic> _$RootHttpModelToJson(RootHttpModel instance) =>
    <String, dynamic>{
      'servers': instance.servers?.map((e) => e.toJson()).toList(),
      'tariffs': instance.tariffs.map((e) => e.toJson()).toList(),
      'user_info': instance.user_info?.toJson(),
    };
