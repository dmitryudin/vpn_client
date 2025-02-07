// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'server_http_model.g.dart';

@JsonSerializable()
class ServerHttpModel {
  int? id;
  String? name;
  String? url;
  String? ip;
  String? username;
  String? country;
  double? load_coef;
  String? password;
  ServerHttpModel({
    this.id,
    this.name,
    this.url,
    this.ip,
    this.username,
    this.country,
    this.load_coef,
    this.password,
  });

  factory ServerHttpModel.fromJson(Map<String, dynamic> json) {
    return _$ServerHttpModelFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ServerHttpModelToJson(this);
}
