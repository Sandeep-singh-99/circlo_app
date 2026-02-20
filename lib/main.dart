import 'package:circlo_app/core/storage/secure_storage.dart';
import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_event.dart';
import 'package:circlo_app/features/auth/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circlo_app/config/theme.dart';
import 'package:circlo_app/router/route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(AuthRepository(), SecureStorageService())
                ..add(AuthCheckRequested()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: createRouter(context.read<AuthBloc>()),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
