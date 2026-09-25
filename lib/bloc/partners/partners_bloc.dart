import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/data_repository.dart';
import 'partners_event.dart';
import 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  final DataRepository repository;

  PartnersBloc(this.repository) : super(const PartnersState()) {
    on<PartnersRequested>(_onPartnersRequested);
  }

  Future<void> _onPartnersRequested(
    PartnersRequested event,
    Emitter<PartnersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final stopwatch = Stopwatch()..start();

      final partners = await repository.getPartners();

      stopwatch.stop();

      print(
        'Partners loaded: ${partners.length} '
        'in ${stopwatch.elapsedMilliseconds} ms',
      );

      emit(
        state.copyWith(isLoading: false, partners: partners, clearError: true),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
