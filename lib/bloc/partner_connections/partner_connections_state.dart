import 'package:equatable/equatable.dart';

import '../../models/partner_connection_data.dart';

class PartnerConnectionsState extends Equatable {
  final bool isLoading;
  final List<PartnerConnectionData> connections;
  final String? errorMessage;

  const PartnerConnectionsState({
    this.isLoading = false,
    this.connections = const [],
    this.errorMessage,
  });

  PartnerConnectionsState copyWith({
    bool? isLoading,
    List<PartnerConnectionData>? connections,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PartnerConnectionsState(
      isLoading: isLoading ?? this.isLoading,
      connections: connections ?? this.connections,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, connections, errorMessage];
}
