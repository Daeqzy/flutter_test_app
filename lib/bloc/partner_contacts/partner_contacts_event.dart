import 'package:equatable/equatable.dart';

abstract class PartnerContactsEvent extends Equatable {
  const PartnerContactsEvent();

  @override
  List<Object?> get props => [];
}

class PartnerContactsRequested extends PartnerContactsEvent {
  final int tp;
  final int p;

  const PartnerContactsRequested({required this.tp, required this.p});

  @override
  List<Object?> get props => [tp, p];
}
