import 'package:flutter_bloc/flutter_bloc.dart';

import 'services_event.dart';
import 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc() : super(const ServicesState()) {
    on<ServicesRequested>(_onServicesRequested);
    on<ServicesSearchChanged>(_onServicesSearchChanged);
  }

  Future<void> _onServicesRequested(
    ServicesRequested event,
    Emitter<ServicesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    // Real API request will go here.

    emit(state.copyWith(isLoading: false));
  }

  void _onServicesSearchChanged(
    ServicesSearchChanged event,
    Emitter<ServicesState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
