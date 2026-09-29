import 'package:equatable/equatable.dart';

abstract class PartnerAgreementsEvent extends Equatable {
  const PartnerAgreementsEvent();

  @override
  List<Object?> get props => [];
}

class PartnerAgreementsRequested extends PartnerAgreementsEvent {
  final int tp;
  final int p;

  const PartnerAgreementsRequested({required this.tp, required this.p});

  @override
  List<Object?> get props => [tp, p];
}
