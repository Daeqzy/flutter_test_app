import 'package:equatable/equatable.dart';

abstract class PartnerConnectionsEvent extends Equatable {
  const PartnerConnectionsEvent();

  @override
  List<Object?> get props => [];
}

class PartnerConnectionsRequested extends PartnerConnectionsEvent {
  final int tp;
  final int p;

  const PartnerConnectionsRequested({required this.tp, required this.p});

  @override
  List<Object?> get props => [tp, p];
}
