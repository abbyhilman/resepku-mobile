import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'splash_screen.dart';

class ResepKuApp extends StatefulWidget {
  const ResepKuApp({super.key});

  @override
  State<ResepKuApp> createState() => _ResepKuAppState();
}

class _ResepKuAppState extends State<ResepKuApp> {
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp(
        title: 'ResepKu',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
