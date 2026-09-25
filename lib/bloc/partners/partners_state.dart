import 'package:equatable/equatable.dart';

import '../../models/mat_partner_data.dart';

class PartnersState extends Equatable {
  final bool isLoading;
  final List<MatPartnerData> partners;
  final String? errorMessage;

  const PartnersState({
    this.isLoading = false,
    this.partners = const [],
    this.errorMessage,
  });

  PartnersState copyWith({
    bool? isLoading,
    List<MatPartnerData>? partners,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PartnersState(
      isLoading: isLoading ?? this.isLoading,
      partners: partners ?? this.partners,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, partners, errorMessage];
}
