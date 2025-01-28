// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_http_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerHttpModel _$ServerHttpModelFromJson(Map<String, dynamic> json) =>
    ServerHttpModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      url: json['url'] as String?,
      ip: json['ip'] as String?,
      username: json['username'] as String?,
      country: json['country'] as String?,
      load_coef: (json['load_coef'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ServerHttpModelToJson(ServerHttpModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'ip': instance.ip,
      'username': instance.username,
      'country': instance.country,
      'load_coef': instance.load_coef,
    };
