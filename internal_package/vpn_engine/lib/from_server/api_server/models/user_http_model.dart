// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'user_http_model.g.dart';

@JsonSerializable()
class UserHttpModel {
  double? balance;
  bool? is_blocked;
  int? current_tarif_id;
  UserHttpModel({this.balance, this.is_blocked, this.current_tarif_id});
  factory UserHttpModel.fromJson(Map<String, dynamic> json) {
    return _$UserHttpModelFromJson(json);
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserHttpModelToJson(this);
}
