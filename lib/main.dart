import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_sources/user_data_sources.dart';
import 'package:flutter_application_1/services/biometric_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'bloc/user/user_bloc.dart';
import 'bloc/user/user_event.dart';
import 'repositories/user_repository.dart';
import 'repositories/data_repository.dart';
import 'network_service/api_service.dart';
import 'network_service/auth_interceptor.dart';
import 'screens/login/login_screen.dart';

void main() {
  // HTTP client
  final dio = Dio();

  // Automatically adds Bearer token to authenticated requests
  dio.interceptors.add(AuthInterceptor());

  // Retrofit API service
  final apiService = ApiService(dio);

  // Repository responsible for API/data operations
  final dataRepository = DataRepository(apiService);

  runApp(
    RepositoryProvider<DataRepository>.value(
      value: dataRepository,
      child: BlocProvider(
        create: (_) => UserBloc(
          UserRepository(UserDataSource(), dataRepository),
          BiometricService(),
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
