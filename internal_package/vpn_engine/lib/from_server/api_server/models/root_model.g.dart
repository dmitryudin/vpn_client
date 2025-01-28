// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RootHttpModel _$RootHttpModelFromJson(Map<String, dynamic> json) =>
    RootHttpModel(
      servers: (json['servers'] as List<dynamic>?)
          ?.map((e) => ServerHttpModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      user_info: json['user_info'] == null
          ? null
          : UserHttpModel.fromJson(json['user_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RootHttpModelToJson(RootHttpModel instance) =>
    <String, dynamic>{
      'servers': instance.servers,
      'user_info': instance.user_info,
    };
