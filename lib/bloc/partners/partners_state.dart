import 'package:equatable/equatable.dart';

import '../../models/mat_partner_data.dart';

// ----------------------------------------------------------
// SORT OPTIONS
// ----------------------------------------------------------

enum PartnerSortOption {
  nameAZ,
  nameZA,
  cityAZ,
  cityZA,
  idAscending,
  idDescending,
}

class PartnersState extends Equatable {
  final bool isLoading;

  // Complete list received from backend.
  final List<MatPartnerData> allPartners;

  // Filtered/sorted list displayed in UI.
  final List<MatPartnerData> partners;

  // Available cities extracted from partners.
  final List<String> cities;

  final String searchQuery;

  // "All" means no city filter.
  final String selectedCity;

  final PartnerSortOption sortOption;

  final String? errorMessage;

  const PartnersState({
    this.isLoading = false,
    this.allPartners = const [],
    this.partners = const [],
    this.cities = const [],
    this.searchQuery = '',
    this.selectedCity = 'All',
    this.sortOption = PartnerSortOption.nameAZ,
    this.errorMessage,
  });

  PartnersState copyWith({
    bool? isLoading,
    List<MatPartnerData>? allPartners,
    List<MatPartnerData>? partners,
    List<String>? cities,
    String? searchQuery,
    String? selectedCity,
    PartnerSortOption? sortOption,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PartnersState(
      isLoading: isLoading ?? this.isLoading,

      allPartners: allPartners ?? this.allPartners,

      partners: partners ?? this.partners,

      cities: cities ?? this.cities,

      searchQuery: searchQuery ?? this.searchQuery,

      selectedCity: selectedCity ?? this.selectedCity,

      sortOption: sortOption ?? this.sortOption,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    allPartners,
    partners,
    cities,
    searchQuery,
    selectedCity,
    sortOption,
    errorMessage,
  ];
}
