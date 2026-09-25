import 'package:json_annotation/json_annotation.dart';

part 'mat_partner_data.g.dart';

@JsonSerializable()
class MatPartnerData {
  @JsonKey(name: 'mesto_naziv')
  final String? mestoNaziv;

  @JsonKey(name: 'select_naziv')
  final String? selectNaziv;

  final String? tpp;

  @JsonKey(name: 'select_naziv_klient')
  final String? selectNazivKlient;

  @JsonKey(name: 'tip_partner')
  final int? tipPartner;

  final int? id;
  final String? naziv;
  final String? adresa;
  final String? tel;
  final String? fax;
  final String? danocen;
  final String? emb;
  final int? mesto;
  final String? ime;
  final String? prezime;
  final String? tatko;

  // C# byte[] is normally returned as a Base64 string in JSON.
  final String? logo;

  final int? re;
  final String? logotext;
  final int? status;
  final double? limit;
  final int? cenovnik;
  final String? email;
  final String? mail;
  final String? url;
  final double? cena;
  final int? aktiven;

  @JsonKey(name: 'naziv_skraten')
  final String? nazivSkraten;

  @JsonKey(name: 'adresa_latitude')
  final double? adresaLatitude;

  @JsonKey(name: 'adresa_longitude')
  final double? adresaLongitude;

  @JsonKey(name: 'pravno_lice')
  final int? pravnoLice;

  @JsonKey(name: 'ts_ins')
  final DateTime? tsIns;

  @JsonKey(name: 'ts_upd')
  final DateTime? tsUpd;

  @JsonKey(name: 'usr_ins')
  final String? usrIns;

  @JsonKey(name: 'usr_upd')
  final String? usrUpd;

  final String? custom1;
  final String? custom2;
  final String? custom3;

  @JsonKey(name: 'val_denovi')
  final int? valDenovi;

  final String? memorandum;

  @JsonKey(name: 'memorandum_text')
  final String? memorandumText;

  @JsonKey(name: 'logo_en')
  final String? logoEn;

  @JsonKey(name: 'logotext_en')
  final String? logotextEn;

  const MatPartnerData({
    this.mestoNaziv,
    this.selectNaziv,
    this.tpp,
    this.selectNazivKlient,
    this.tipPartner,
    this.id,
    this.naziv,
    this.adresa,
    this.tel,
    this.fax,
    this.danocen,
    this.emb,
    this.mesto,
    this.ime,
    this.prezime,
    this.tatko,
    this.logo,
    this.re,
    this.logotext,
    this.status,
    this.limit,
    this.cenovnik,
    this.email,
    this.mail,
    this.url,
    this.cena,
    this.aktiven,
    this.nazivSkraten,
    this.adresaLatitude,
    this.adresaLongitude,
    this.pravnoLice,
    this.tsIns,
    this.tsUpd,
    this.usrIns,
    this.usrUpd,
    this.custom1,
    this.custom2,
    this.custom3,
    this.valDenovi,
    this.memorandum,
    this.memorandumText,
    this.logoEn,
    this.logotextEn,
  });

  factory MatPartnerData.fromJson(Map<String, dynamic> json) =>
      _$MatPartnerDataFromJson(json);

  Map<String, dynamic> toJson() => _$MatPartnerDataToJson(this);
}
