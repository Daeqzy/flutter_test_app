import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/preferences_service.dart';
import 'preferences_event.dart';
import 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferencesService preferencesService;

  PreferencesBloc({required this.preferencesService})
    : super(const PreferencesState()) {
    on<PreferencesStarted>(_onStarted);
    on<ThemeModeChanged>(_onThemeModeChanged);
  }

  Future<void> _onStarted(
    PreferencesStarted event,
    Emitter<PreferencesState> emit,
  ) async {
    final themeMode = await preferencesService.loadThemeMode();

    emit(state.copyWith(themeMode: themeMode, isLoading: false));
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));

    await preferencesService.saveThemeMode(event.themeMode);
  }
}
