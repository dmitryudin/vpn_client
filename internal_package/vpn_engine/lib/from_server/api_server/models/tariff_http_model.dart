// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'tariff_http_model.g.dart';

@JsonSerializable()
class TariffHttpModel {
  int? id;
  String? descryption;
  double? cost_in_day;
  int? max_number_of_devices;
  TariffHttpModel({
    this.id,
    this.descryption,
    this.cost_in_day,
    this.max_number_of_devices,
  });

  factory TariffHttpModel.fromJson(Map<String, dynamic> json) {
    return _$TariffHttpModelFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TariffHttpModelToJson(this);
}
