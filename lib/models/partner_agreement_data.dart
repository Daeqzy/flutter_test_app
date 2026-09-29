import 'package:json_annotation/json_annotation.dart';

part 'partner_agreement_data.g.dart';

@JsonSerializable()
class PartnerAgreementData {
  final int? broj;

  @JsonKey(name: 'dogovor_br')
  final String? dogovorBr;

  @JsonKey(name: 'vid_dogovor')
  final int? vidDogovor;

  @JsonKey(name: 'vid_dogovor_show')
  final String? vidDogovorShow;

  final String? opis;

  @JsonKey(name: 'datum_potpis')
  final DateTime? datumPotpis;

  @JsonKey(name: 'datum_od')
  final DateTime? datumOd;

  @JsonKey(name: 'datum_do')
  final DateTime? datumDo;

  final String? status;

  final int? re;

  const PartnerAgreementData({
    this.broj,
    this.dogovorBr,
    this.vidDogovor,
    this.vidDogovorShow,
    this.opis,
    this.datumPotpis,
    this.datumOd,
    this.datumDo,
    this.status,
    this.re,
  });

  factory PartnerAgreementData.fromJson(Map<String, dynamic> json) =>
      _$PartnerAgreementDataFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerAgreementDataToJson(this);
}
