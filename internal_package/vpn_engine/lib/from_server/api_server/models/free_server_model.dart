import 'package:json_annotation/json_annotation.dart';

import 'package:vpn_engine/from_server/api_server/models/server_http_model.dart';
import 'package:vpn_engine/from_server/api_server/models/tariff_http_model.dart';
import 'package:vpn_engine/from_server/api_server/models/user_http_model.dart';

part 'free_server_model.g.dart';

@JsonSerializable()
class FreeServerHttpModel {
  List<ServerHttpModel>? servers;
  List<TariffHttpModel> tariffs;

  FreeServerHttpModel({
    this.servers,
    required this.tariffs,
  });

  factory FreeServerHttpModel.fromJson(Map<String, dynamic> json) {
    return _$FreeServerHttpModelFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FreeServerHttpModelToJson(this);
}
