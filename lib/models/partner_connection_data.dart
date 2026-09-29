import 'package:json_annotation/json_annotation.dart';

part 'partner_connection_data.g.dart';

@JsonSerializable()
class PartnerConnectionData {
  final int? id;
  final String? naziv;
  final int? tp;
  final int? p;

  @JsonKey(name: 'public_ip')
  final String? publicIp;

  @JsonKey(name: 'ddns_name')
  final String? ddnsName;

  final String? adresa;

  @JsonKey(name: 'lan_info')
  final String? lanInfo;

  @JsonKey(name: 'os_info')
  final String? osInfo;

  final int? aktiven;

  @JsonKey(name: 'aktiven_bool')
  final bool? aktivenBool;

  @JsonKey(name: 'aktiven_string')
  final String? aktivenString;

  const PartnerConnectionData({
    this.id,
    this.naziv,
    this.tp,
    this.p,
    this.publicIp,
    this.ddnsName,
    this.adresa,
    this.lanInfo,
    this.osInfo,
    this.aktiven,
    this.aktivenBool,
    this.aktivenString,
  });

  factory PartnerConnectionData.fromJson(Map<String, dynamic> json) =>
      _$PartnerConnectionDataFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerConnectionDataToJson(this);
}
