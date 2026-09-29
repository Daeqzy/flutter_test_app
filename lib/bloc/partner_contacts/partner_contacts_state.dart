import 'package:equatable/equatable.dart';

import '../../models/partner_contact_data.dart';

class PartnerContactsState extends Equatable {
  final bool isLoading;
  final List<PartnerContactData> contacts;
  final String? errorMessage;

  const PartnerContactsState({
    this.isLoading = false,
    this.contacts = const [],
    this.errorMessage,
  });

  PartnerContactsState copyWith({
    bool? isLoading,
    List<PartnerContactData>? contacts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PartnerContactsState(
      isLoading: isLoading ?? this.isLoading,
      contacts: contacts ?? this.contacts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, contacts, errorMessage];
}
