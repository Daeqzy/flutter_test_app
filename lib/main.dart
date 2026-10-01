import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'config/app_config.dart';

import 'data_sources/user_data_sources.dart';

import 'bloc/user/user_bloc.dart';
import 'bloc/user/user_event.dart';

import 'bloc/preferences/preferences_bloc.dart';
import 'bloc/preferences/preferences_event.dart';
import 'bloc/preferences/preferences_state.dart';

import 'repositories/user_repository.dart';
import 'repositories/data_repository.dart';

import 'network_service/api_service.dart';
import 'network_service/auth_interceptor.dart';

import 'services/biometric_service.dart';
import 'services/auth_session_service.dart';
import 'services/preferences_service.dart';

import 'screens/login/login_screen.dart';

import 'theme/app_theme.dart';

void main() {
  // ----------------------------------------------------------
  // AUTH SESSION SERVICE
  // ----------------------------------------------------------

  final authSessionService = AuthSessionService();

  // ----------------------------------------------------------
  // DIO
  // ----------------------------------------------------------

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),

      receiveTimeout: const Duration(seconds: 30),

      sendTimeout: const Duration(seconds: 15),
    ),
  );

  // ----------------------------------------------------------
  // AUTH INTERCEPTOR
  // ----------------------------------------------------------

  dio.interceptors.add(AuthInterceptor(authSessionService));

  // ----------------------------------------------------------
  // RETROFIT API SERVICE
  // ----------------------------------------------------------

  final apiService = ApiService(dio, baseUrl: AppConfig.baseUrl);

  // ----------------------------------------------------------
  // DATA REPOSITORY
  // ----------------------------------------------------------

  final dataRepository = DataRepository(apiService);

  // ----------------------------------------------------------
  // APP
  // ----------------------------------------------------------

  runApp(
    RepositoryProvider<DataRepository>.value(
      value: dataRepository,

      child: MultiBlocProvider(
        providers: [
          // ------------------------------------------------------
          // USER BLOC
          // ------------------------------------------------------

          BlocProvider(
            create: (_) => UserBloc(
              UserRepository(UserDataSource(), dataRepository),
              BiometricService(),
              authSessionService,
            )..add(const CheckRememberedSession()),
          ),

          // ------------------------------------------------------
          // PREFERENCES BLOC
          // ------------------------------------------------------
          BlocProvider(
            create: (_) =>
                PreferencesBloc(preferencesService: PreferencesService())
                  ..add(const PreferencesStarted()),
          ),
        ],

        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PreferencesState>(
      buildWhen: (previous, current) {
        return previous.themeMode != current.themeMode;
      },
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CODEX Computers',

          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.themeMode,

          home: LoginScreen(),
        );
      },
    );
  }
}
