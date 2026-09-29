import 'package:equatable/equatable.dart';

import 'partners_state.dart';

abstract class PartnersEvent extends Equatable {
  const PartnersEvent();

  @override
  List<Object?> get props => [];
}

// ----------------------------------------------------------
// LOAD PARTNERS
// ----------------------------------------------------------

class PartnersRequested extends PartnersEvent {
  const PartnersRequested();
}

// ----------------------------------------------------------
// SEARCH BY NAME
// ----------------------------------------------------------

class PartnersSearchChanged extends PartnersEvent {
  final String query;

  const PartnersSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

// ----------------------------------------------------------
// FILTER BY CITY
// ----------------------------------------------------------

class PartnersCityChanged extends PartnersEvent {
  final String city;

  const PartnersCityChanged(this.city);

  @override
  List<Object?> get props => [city];
}

// ----------------------------------------------------------
// SORT
// ----------------------------------------------------------

class PartnersSortChanged extends PartnersEvent {
  final PartnerSortOption sortOption;

  const PartnersSortChanged(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}
