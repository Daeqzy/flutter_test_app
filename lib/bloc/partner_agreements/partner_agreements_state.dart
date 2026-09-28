import 'package:equatable/equatable.dart';

import '../../models/partner_agreement_data.dart';

class PartnerAgreementsState extends Equatable {
  final bool isLoading;
  final List<PartnerAgreementData> agreements;
  final String? errorMessage;

  const PartnerAgreementsState({
    this.isLoading = false,
    this.agreements = const [],
    this.errorMessage,
  });

  PartnerAgreementsState copyWith({
    bool? isLoading,
    List<PartnerAgreementData>? agreements,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PartnerAgreementsState(
      isLoading: isLoading ?? this.isLoading,
      agreements: agreements ?? this.agreements,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, agreements, errorMessage];
}
