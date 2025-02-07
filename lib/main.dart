import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tot_app/bloc/dog_screen_bloc.dart';
import 'package:tot_app/constants/theme/app_theme.dart';
import 'package:tot_app/data/repositories/dog_repo.dart';
import 'package:tot_app/presentation/dog_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DogScreenBloc(dogRepo: DogRepo()),
      child: MaterialApp(
          title: 'TOT APP',
          theme: AppTheme.lightTheme,
          home: const DogHomeScreen()),
    );
  }
}
