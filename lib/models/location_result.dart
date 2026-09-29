import 'package:json_annotation/json_annotation.dart';

part 'location_result.g.dart';

@JsonSerializable()
class LocationResult {
  final int? o_id;
  final String? o_address_number;
  final String? o_address;
  final String? o_name_owner;

  LocationResult({
    this.o_id,
    this.o_address_number,
    this.o_address,
    this.o_name_owner,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) =>
      _$LocationResultFromJson(json);

  Map<String, dynamic> toJson() => _$LocationResultToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationResult &&
          runtimeType == other.runtimeType &&
          o_id == other.o_id;
}
