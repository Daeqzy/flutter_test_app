import 'package:equatable/equatable.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object?> get props => [];
}

class ServicesRequested extends ServicesEvent {
  const ServicesRequested();
}

class ServicesSearchChanged extends ServicesEvent {
  final String query;

  const ServicesSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
