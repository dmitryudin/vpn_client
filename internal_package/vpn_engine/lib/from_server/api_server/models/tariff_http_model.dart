// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'tariff_http_model.g.dart';

@JsonSerializable()
class TariffHttpModel {
  int? id;
  String? name;
  String? descryption;
  double? days;
  double? cost;
  int? max_number_of_devices;
  TariffHttpModel(
      {this.id,
      this.descryption,
      this.days,
      this.cost,
      this.max_number_of_devices,
      this.name});

  factory TariffHttpModel.fromJson(Map<String, dynamic> json) {
    return _$TariffHttpModelFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TariffHttpModelToJson(this);
}
