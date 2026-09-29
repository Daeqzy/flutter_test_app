import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/data_repository.dart';
import 'partner_connections_event.dart';
import 'partner_connections_state.dart';

class PartnerConnectionsBloc
    extends Bloc<PartnerConnectionsEvent, PartnerConnectionsState> {
  final DataRepository repository;

  PartnerConnectionsBloc(this.repository)
    : super(const PartnerConnectionsState()) {
    on<PartnerConnectionsRequested>(_onPartnerConnectionsRequested);
  }

  Future<void> _onPartnerConnectionsRequested(
    PartnerConnectionsRequested event,
    Emitter<PartnerConnectionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final connections = await repository.getPartnerConnections(
        event.tp,
        event.p,
      );

      emit(
        state.copyWith(
          isLoading: false,
          connections: connections,
          clearError: true,
        ),
      );
    } on DioException catch (e) {
      String message = 'Failed to load connections.';

      final statusCode = e.response?.statusCode;

      if (statusCode == 400) {
        message = 'Invalid partner connection parameters.';
      } else if (statusCode == 401) {
        message = 'Your session has expired. Please log in again.';
      } else if (statusCode == 403) {
        message = 'You do not have permission to view these connections.';
      } else if (statusCode == 404) {
        message = 'Connection information was not found.';
      } else if (statusCode != null && statusCode >= 500) {
        message = 'Server error. Please try again later.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        message = 'The request timed out. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Could not connect to the server.';
      }

      emit(state.copyWith(isLoading: false, errorMessage: message));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Something went wrong.'),
      );
    }
  }
}
