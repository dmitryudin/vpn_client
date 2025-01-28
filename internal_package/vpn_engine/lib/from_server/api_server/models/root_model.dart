// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

import 'package:vpn_engine/from_server/api_server/models/server_http_model.dart';
import 'package:vpn_engine/from_server/api_server/models/tariff_http_model.dart';
import 'package:vpn_engine/from_server/api_server/models/user_http_model.dart';

part 'root_model.g.dart';

@JsonSerializable()
class RootHttpModel {
  List<ServerHttpModel>? servers;
  List<TariffHttpModel> tariffs;
  UserHttpModel? user_info;

  RootHttpModel({
    this.servers,
    required this.tariffs,
    this.user_info,
  });

  factory RootHttpModel.fromJson(Map<String, dynamic> json) {
    return _$RootHttpModelFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$RootHttpModelToJson(this);
}
