import 'package:json_annotation/json_annotation.dart';

part 'change_password_request.g.dart';

@JsonSerializable()
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ChangePasswordRequestToJson(this);
}