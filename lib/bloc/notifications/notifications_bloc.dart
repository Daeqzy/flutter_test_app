import 'package:flutter_bloc/flutter_bloc.dart';

import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationsRequested>(_onNotificationsRequested);
  }

  Future<void> _onNotificationsRequested(
    NotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    // Real API request will go here later.

    emit(state.copyWith(isLoading: false, clearError: true));
  }
}
