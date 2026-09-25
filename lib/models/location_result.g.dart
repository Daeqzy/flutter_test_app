// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationResult _$LocationResultFromJson(Map<String, dynamic> json) =>
    LocationResult(
      o_id: (json['o_id'] as num?)?.toInt(),
      o_address_number: json['o_address_number'] as String?,
      o_address: json['o_address'] as String?,
      o_name_owner: json['o_name_owner'] as String?,
    );

Map<String, dynamic> _$LocationResultToJson(LocationResult instance) =>
    <String, dynamic>{
      'o_id': instance.o_id,
      'o_address_number': instance.o_address_number,
      'o_address': instance.o_address,
      'o_name_owner': instance.o_name_owner,
    };
