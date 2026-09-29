import 'package:json_annotation/json_annotation.dart';

part 'partner_contact_data.g.dart';

@JsonSerializable()
class PartnerContactData {
  final int? id;
  final String? naziv;
  final String? tel;
  final String? mobilen;
  final String? mail;
  final String? opis;

  const PartnerContactData({
    this.id,
    this.naziv,
    this.tel,
    this.mobilen,
    this.mail,
    this.opis,
  });

  factory PartnerContactData.fromJson(Map<String, dynamic> json) =>
      _$PartnerContactDataFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerContactDataToJson(this);
}
