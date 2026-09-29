// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_agreement_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerAgreementData _$PartnerAgreementDataFromJson(
  Map<String, dynamic> json,
) => PartnerAgreementData(
  broj: (json['broj'] as num?)?.toInt(),
  dogovorBr: json['dogovor_br'] as String?,
  vidDogovor: (json['vid_dogovor'] as num?)?.toInt(),
  vidDogovorShow: json['vid_dogovor_show'] as String?,
  opis: json['opis'] as String?,
  datumPotpis: json['datum_potpis'] == null
      ? null
      : DateTime.parse(json['datum_potpis'] as String),
  datumOd: json['datum_od'] == null
      ? null
      : DateTime.parse(json['datum_od'] as String),
  datumDo: json['datum_do'] == null
      ? null
      : DateTime.parse(json['datum_do'] as String),
  status: json['status'] as String?,
  re: (json['re'] as num?)?.toInt(),
);

Map<String, dynamic> _$PartnerAgreementDataToJson(
  PartnerAgreementData instance,
) => <String, dynamic>{
  'broj': instance.broj,
  'dogovor_br': instance.dogovorBr,
  'vid_dogovor': instance.vidDogovor,
  'vid_dogovor_show': instance.vidDogovorShow,
  'opis': instance.opis,
  'datum_potpis': instance.datumPotpis?.toIso8601String(),
  'datum_od': instance.datumOd?.toIso8601String(),
  'datum_do': instance.datumDo?.toIso8601String(),
  'status': instance.status,
  're': instance.re,
};
