import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'data_sources/user_data_sources.dart';

import 'bloc/user/user_bloc.dart';
import 'bloc/user/user_event.dart';

import 'repositories/user_repository.dart';
import 'repositories/data_repository.dart';

import 'network_service/api_service.dart';
import 'network_service/auth_interceptor.dart';

import 'services/biometric_service.dart';
import 'services/auth_session_service.dart';

import 'screens/login/login_screen.dart';

void main() {
  // ----------------------------------------------------------
  // AUTH SESSION SERVICE
  // ----------------------------------------------------------
  //
  // Shared messenger between:
  //
  // AuthInterceptor
  //        ↓
  // UserBloc
  //
  // When the API returns 401, the interceptor notifies this
  // service and UserBloc reacts to the expired session.
  // ----------------------------------------------------------

  final authSessionService = AuthSessionService();

  // ----------------------------------------------------------
  // HTTP CLIENT
  // ----------------------------------------------------------

  final dio = Dio();

  // Automatically:
  //
  // 1. Adds Bearer token to authenticated requests
  // 2. Detects 401 session expiration
  // 3. Clears expired tokens
  // 4. Notifies AuthSessionService
  dio.interceptors.add(AuthInterceptor(authSessionService));

  // ----------------------------------------------------------
  // RETROFIT API SERVICE
  // ----------------------------------------------------------

  final apiService = ApiService(dio);

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

      child: BlocProvider(
        create: (_) => UserBloc(
          UserRepository(UserDataSource(), dataRepository),

          BiometricService(),

          authSessionService,
        )..add(const CheckRememberedSession()),

        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'CODEX Computers',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),

        fontFamily: 'Roboto',
      ),

      home: LoginScreen(),
    );
  }
}
