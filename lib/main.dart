import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/map_bloc/bloc_map.dart';
import 'package:tot_app/constants/theme/app_theme.dart';
import 'package:tot_app/data/model/dog_model.dart';
import 'package:tot_app/data/repositories/dog_repo.dart';
import 'package:tot_app/data/repositories/map_repo.dart';
import 'package:tot_app/data/repositories/tryMap.dart';
import 'package:tot_app/presentation/dog_home_screen.dart';
import 'package:geolocator/geolocator.dart';

import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(DogModelAdapter());
  await Hive.openBox<DogModel>('savedDogs');

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<DogScreenBloc>(
          create: (context) => DogScreenBloc(dogRepo: DogRepo())
            ..add(FetchDogs())
            ..add(LoadSavedDogs()),
        ),
        BlocProvider<RideBloc>(
          create: (context) => RideBloc(
            routeRepository: RouteRepository(),
            locationRepository: LocationRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'TOT App',
        theme: AppTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}

class LocationPermissionHandler {
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services'),
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied'),
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return false;
    }

    return true;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    context.read<DogScreenBloc>().add(LoadSavedDogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DogHomeScreen(),
          TrackingScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
