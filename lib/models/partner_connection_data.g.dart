// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_connection_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerConnectionData _$PartnerConnectionDataFromJson(
  Map<String, dynamic> json,
) => PartnerConnectionData(
  id: (json['id'] as num?)?.toInt(),
  naziv: json['naziv'] as String?,
  tp: (json['tp'] as num?)?.toInt(),
  p: (json['p'] as num?)?.toInt(),
  publicIp: json['public_ip'] as String?,
  ddnsName: json['ddns_name'] as String?,
  adresa: json['adresa'] as String?,
  lanInfo: json['lan_info'] as String?,
  osInfo: json['os_info'] as String?,
  aktiven: (json['aktiven'] as num?)?.toInt(),
  aktivenBool: json['aktiven_bool'] as bool?,
  aktivenString: json['aktiven_string'] as String?,
);

Map<String, dynamic> _$PartnerConnectionDataToJson(
  PartnerConnectionData instance,
) => <String, dynamic>{
  'id': instance.id,
  'naziv': instance.naziv,
  'tp': instance.tp,
  'p': instance.p,
  'public_ip': instance.publicIp,
  'ddns_name': instance.ddnsName,
  'adresa': instance.adresa,
  'lan_info': instance.lanInfo,
  'os_info': instance.osInfo,
  'aktiven': instance.aktiven,
  'aktiven_bool': instance.aktivenBool,
  'aktiven_string': instance.aktivenString,
};
