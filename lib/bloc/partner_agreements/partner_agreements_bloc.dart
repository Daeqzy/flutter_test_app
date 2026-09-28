import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/data_repository.dart';
import 'partner_agreements_event.dart';
import 'partner_agreements_state.dart';

class PartnerAgreementsBloc
    extends Bloc<PartnerAgreementsEvent, PartnerAgreementsState> {
  final DataRepository repository;

  PartnerAgreementsBloc(this.repository)
    : super(const PartnerAgreementsState()) {
    on<PartnerAgreementsRequested>(_onPartnerAgreementsRequested);
  }

  Future<void> _onPartnerAgreementsRequested(
    PartnerAgreementsRequested event,
    Emitter<PartnerAgreementsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final agreements = await repository.getPartnerAgreements(
        event.tp,
        event.p,
      );

      emit(
        state.copyWith(
          isLoading: false,
          agreements: agreements,
          clearError: true,
        ),
      );
    } on DioException catch (e) {
      String message = 'Failed to load agreements.';

      final statusCode = e.response?.statusCode;

      if (statusCode == 400) {
        message = 'Invalid partner agreement parameters.';
      } else if (statusCode == 401) {
        message = 'Your session has expired. Please log in again.';
      } else if (statusCode == 403) {
        message = 'You do not have permission to view these agreements.';
      } else if (statusCode == 404) {
        message = 'Agreement information was not found.';
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
