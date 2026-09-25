import 'package:equatable/equatable.dart';

class ServicesState extends Equatable {
  final bool isLoading;
  final String searchQuery;
  final String? errorMessage;

  const ServicesState({
    this.isLoading = false,
    this.searchQuery = '',
    this.errorMessage,
  });

  ServicesState copyWith({
    bool? isLoading,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, searchQuery, errorMessage];
}
