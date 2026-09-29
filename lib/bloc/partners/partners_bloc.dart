import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/mat_partner_data.dart';
import '../../repositories/data_repository.dart';

import 'partners_event.dart';
import 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  final DataRepository repository;

  PartnersBloc(this.repository) : super(const PartnersState()) {
    on<PartnersRequested>(_onPartnersRequested);

    on<PartnersSearchChanged>(_onPartnersSearchChanged);

    on<PartnersCityChanged>(_onPartnersCityChanged);

    on<PartnersSortChanged>(_onPartnersSortChanged);
  }

  // ----------------------------------------------------------
  // LOAD PARTNERS
  // ----------------------------------------------------------

  Future<void> _onPartnersRequested(
    PartnersRequested event,
    Emitter<PartnersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final stopwatch = Stopwatch()..start();

      final allPartners = await repository.getPartners();

      stopwatch.stop();

      print(
        'Partners loaded: ${allPartners.length} '
        'in ${stopwatch.elapsedMilliseconds} ms',
      );

      // Extract every unique city.
      final cities = allPartners
          .map((partner) => partner.mestoNaziv?.trim())
          .whereType<String>()
          .where((city) => city.isNotEmpty)
          .toSet()
          .toList();

      // Sort city list alphabetically.
      cities.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      final visiblePartners = _filterAndSort(
        source: allPartners,
        searchQuery: state.searchQuery,
        selectedCity: state.selectedCity,
        sortOption: state.sortOption,
      );

      emit(
        state.copyWith(
          isLoading: false,

          allPartners: allPartners,

          partners: visiblePartners,

          cities: cities,

          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // ----------------------------------------------------------
  // SEARCH
  // ----------------------------------------------------------

  void _onPartnersSearchChanged(
    PartnersSearchChanged event,
    Emitter<PartnersState> emit,
  ) {
    final visiblePartners = _filterAndSort(
      source: state.allPartners,

      searchQuery: event.query,

      selectedCity: state.selectedCity,

      sortOption: state.sortOption,
    );

    emit(state.copyWith(searchQuery: event.query, partners: visiblePartners));
  }

  // ----------------------------------------------------------
  // CITY FILTER
  // ----------------------------------------------------------

  void _onPartnersCityChanged(
    PartnersCityChanged event,
    Emitter<PartnersState> emit,
  ) {
    final visiblePartners = _filterAndSort(
      source: state.allPartners,

      searchQuery: state.searchQuery,

      selectedCity: event.city,

      sortOption: state.sortOption,
    );

    emit(state.copyWith(selectedCity: event.city, partners: visiblePartners));
  }

  // ----------------------------------------------------------
  // SORT
  // ----------------------------------------------------------

  void _onPartnersSortChanged(
    PartnersSortChanged event,
    Emitter<PartnersState> emit,
  ) {
    final visiblePartners = _filterAndSort(
      source: state.allPartners,

      searchQuery: state.searchQuery,

      selectedCity: state.selectedCity,

      sortOption: event.sortOption,
    );

    emit(
      state.copyWith(sortOption: event.sortOption, partners: visiblePartners),
    );
  }

  // ----------------------------------------------------------
  // FILTER + SORT ENGINE
  // ----------------------------------------------------------

  List<MatPartnerData> _filterAndSort({
    required List<MatPartnerData> source,
    required String searchQuery,
    required String selectedCity,
    required PartnerSortOption sortOption,
  }) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    final result = source.where((partner) {
      // ----------------------------------------------------
      // SEARCH NAME
      // ----------------------------------------------------

      final partnerName = partner.naziv?.trim().toLowerCase() ?? '';

      final matchesSearch =
          normalizedQuery.isEmpty || partnerName.contains(normalizedQuery);

      // ----------------------------------------------------
      // CITY
      // ----------------------------------------------------

      final partnerCity = partner.mestoNaziv?.trim() ?? '';

      final matchesCity = selectedCity == 'All' || partnerCity == selectedCity;

      return matchesSearch && matchesCity;
    }).toList();

    // --------------------------------------------------------
    // SORT
    // --------------------------------------------------------

    switch (sortOption) {
      case PartnerSortOption.nameAZ:
        result.sort((a, b) {
          final aName = a.naziv?.trim().toLowerCase() ?? '';

          final bName = b.naziv?.trim().toLowerCase() ?? '';

          return aName.compareTo(bName);
        });

        break;

      case PartnerSortOption.nameZA:
        result.sort((a, b) {
          final aName = a.naziv?.trim().toLowerCase() ?? '';

          final bName = b.naziv?.trim().toLowerCase() ?? '';

          return bName.compareTo(aName);
        });

        break;

      case PartnerSortOption.cityAZ:
        result.sort((a, b) {
          final aCity = a.mestoNaziv?.trim().toLowerCase() ?? '';

          final bCity = b.mestoNaziv?.trim().toLowerCase() ?? '';

          return aCity.compareTo(bCity);
        });

        break;

      case PartnerSortOption.cityZA:
        result.sort((a, b) {
          final aCity = a.mestoNaziv?.trim().toLowerCase() ?? '';

          final bCity = b.mestoNaziv?.trim().toLowerCase() ?? '';

          return bCity.compareTo(aCity);
        });

        break;

      case PartnerSortOption.idAscending:
        result.sort((a, b) {
          final aId = a.id;
          final bId = b.id;

          // Keep null IDs at the bottom.
          if (aId == null && bId == null) {
            return 0;
          }

          if (aId == null) {
            return 1;
          }

          if (bId == null) {
            return -1;
          }

          return aId.compareTo(bId);
        });

        break;

      case PartnerSortOption.idDescending:
        result.sort((a, b) {
          final aId = a.id;
          final bId = b.id;

          // Keep null IDs at the bottom.
          if (aId == null && bId == null) {
            return 0;
          }

          if (aId == null) {
            return 1;
          }

          if (bId == null) {
            return -1;
          }

          return bId.compareTo(aId);
        });

        break;
    }

    return result;
  }
}
