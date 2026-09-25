import 'package:equatable/equatable.dart';

abstract class PartnersEvent extends Equatable {
  const PartnersEvent();

  @override
  List<Object?> get props => [];
}

class PartnersRequested extends PartnersEvent {
  const PartnersRequested();
}
