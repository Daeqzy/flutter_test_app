// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_contact_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerContactData _$PartnerContactDataFromJson(Map<String, dynamic> json) =>
    PartnerContactData(
      id: (json['id'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
      tel: json['tel'] as String?,
      mobilen: json['mobilen'] as String?,
      mail: json['mail'] as String?,
      opis: json['opis'] as String?,
    );

Map<String, dynamic> _$PartnerContactDataToJson(PartnerContactData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'naziv': instance.naziv,
      'tel': instance.tel,
      'mobilen': instance.mobilen,
      'mail': instance.mail,
      'opis': instance.opis,
    };
