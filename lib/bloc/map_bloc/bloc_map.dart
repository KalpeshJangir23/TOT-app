import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tot_app/bloc/map_bloc/map_event.dart';
import 'package:tot_app/bloc/map_bloc/map_state.dart';
import 'package:tot_app/data/repositories/map_repo.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final RouteRepository routeRepository;
  final LocationRepository locationRepository;

  GoogleMapController? _mapController;
  StreamSubscription<Position>?
      _locationSubscription; // Changed type to Position
  DateTime? _startTime;
  double _totalDistance = 0.0;
  LatLng? _startPosition;
  LatLng? _currentPosition;

  RideBloc({required this.routeRepository, required this.locationRepository})
      : super(RideInitial()) {
    on<StartRide>(_onStartRide);
    on<StopRide>(_onStopRide);
    on<MapCreated>(_onMapCreated);
  }

  void _onMapCreated(MapCreated event, Emitter<RideState> emit) {
    try {
      _mapController = event.controller;
      _initializeCurrentLocation();
    } catch (e) {
      print('Error setting map controller: $e');
    }
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(position.latitude, position.longitude);
      _updateCamera(_currentPosition!);
    } catch (e) {
      print('Error getting initial location: $e');
    }
  }

  void _updateCamera(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  final List<LatLng> _coordinates = [];

  Future<void> _onStartRide(StartRide event, Emitter<RideState> emit) async {
    try {
      emit(RidePreparation());
      await Future.delayed(const Duration(seconds: 5));

      _startTime = DateTime.now();
      _coordinates.clear();
      _totalDistance = 0.0;
      _startPosition = _currentPosition;

      if (_currentPosition != null) {
        _coordinates.add(_currentPosition!);
      }

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (Position position) {
          final latLng = LatLng(position.latitude, position.longitude);
          _currentPosition = latLng;
          if (latLng != null) {
            _coordinates.add(latLng);
            _updateRoute();
            _updateCamera(latLng);
          }
        },
        onError: (error) {
          emit(RideError(error.toString()));
          _locationSubscription?.cancel();
        },
      );

      emit(RideInProgress(
        polyline: const Polyline(polylineId: PolylineId('route')),
        duration: Duration.zero,
        distance: 0.0,
        startPosition: _startPosition,
        currentPosition: _currentPosition,
      ));
    } catch (e) {
      emit(RideError(e.toString()));
    }
  }

  Future<void> _updateRoute() async {
    if (_coordinates.length < 2) return;

    try {
      final route = await routeRepository.getRoute(_coordinates.toList());
      final distance = _totalDistance + route.distance;

      emit(RideInProgress(
        polyline: Polyline(
          polylineId: const PolylineId('route'),
          points: route.points,
          color: Colors.blue,
          width: 5,
        ),
        duration: DateTime.now().difference(_startTime!),
        distance: distance,
        startPosition: _startPosition,
        currentPosition: _currentPosition,
      ));
    } catch (e) {
      emit(RideError('Failed to update route: ${e.toString()}'));
    }
  }

  void _onStopRide(StopRide event, Emitter<RideState> emit) {
    _locationSubscription?.cancel();
    _startPosition = null;
    _currentPosition = null;
    emit(RideInitial());
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    _mapController?.dispose();
    return super.close();
  }
}
