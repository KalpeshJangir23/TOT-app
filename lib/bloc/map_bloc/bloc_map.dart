import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:tot_app/bloc/map_bloc/map_event.dart';
import 'package:tot_app/bloc/map_bloc/map_state.dart';
import 'package:tot_app/data/repositories/map_repo.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final OsrmRepository _repository;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _updateTimer;
  DateTime? _startTime;

  LocationBloc({OsrmRepository? repository})
      : _repository = repository ?? OsrmRepository(),
        super(LocationState()) {
    on<StartTracking>(_onStartTracking);
    on<UpdateCurrentPosition>(_onUpdateCurrentPosition);
    on<StopTracking>(_onStopTracking);
    on<ResetTracking>(_onResetTracking);
    on<PauseTracking>(_onPauseTracking);
    on<ResumeTracking>(_onResumeTracking);
  }

  Future<void> _onStartTracking(
      StartTracking event, Emitter<LocationState> emit) async {
    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are required!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get initial position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final currentPosition = LatLng(position.latitude, position.longitude);

      // Set start time
      _startTime = DateTime.now();

      // Update state with initial position
      emit(state.copyWith(
        currentPosition: currentPosition,
        source: currentPosition,
        routeCoordinates: [currentPosition],
        isTracking: true,
        isPaused: false,
        error: null,
        startTime: _startTime,
      ));

      // Configure location settings
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Update every 5 meters
        timeLimit: Duration(seconds: 30), // Timeout for getting location
      );

      // Start location stream
      await _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          add(UpdateCurrentPosition(LatLng(position.latitude, position.longitude)));
        },
        onError: (error) {
          print('Location stream error: $error');
          emit(state.copyWith(
            error: 'Error tracking location. Please try again.',
            isTracking: false,
          ));
          add(StopTracking());
        },
        cancelOnError: true,
      );

      // Start periodic updates for duration
      _updateTimer?.cancel();
      _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.isTracking && !state.isPaused) {
          final currentDuration = DateTime.now().difference(_startTime!);
          emit(state.copyWith(duration: currentDuration));
        }
      });

    } catch (e) {
      print('Error starting tracking: $e');
      emit(state.copyWith(
        error: 'Failed to start tracking. Please check your location settings.',
        isTracking: false,
      ));
    }
  }

  void _onUpdateCurrentPosition(
      UpdateCurrentPosition event, Emitter<LocationState> emit) {
    if (!state.isTracking || state.isPaused) return;

    try {
      // Calculate distance from last point
      final lastPoint = state.routeCoordinates.last;
      final distance = const Distance().as(
        LengthUnit.Kilometer,
        lastPoint,
        event.position,
      );

      // Only update if moved more than 5 meters to reduce noise
      if (distance > 0.005) {
        emit(state.copyWith(
          currentPosition: event.position,
          routeCoordinates: [...state.routeCoordinates, event.position],
          error: null,
        ));
      }
    } catch (e) {
      print('Error updating position: $e');
    }
  }

  Future<void> _onStopTracking(
      StopTracking event, Emitter<LocationState> emit) async {
    try {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      _updateTimer?.cancel();
      _updateTimer = null;

      if (state.source != null && state.currentPosition != null) {
        final journey = await _repository.getRouteDetails(
          state.source!,
          state.currentPosition!,
        );

        emit(state.copyWith(
          destination: state.currentPosition,
          journey: journey,
          isTracking: false,
          isPaused: false,
          error: null,
        ));
      } else {
        emit(state.copyWith(
          isTracking: false,
          isPaused: false,
        ));
      }
    } catch (e) {
      print('Error stopping tracking: $e');
      emit(state.copyWith(
        error: 'Error saving journey details.',
        isTracking: false,
        isPaused: false,
      ));
    }
  }

  void _onResetTracking(ResetTracking event, Emitter<LocationState> emit) {
    _positionSubscription?.cancel();
    _updateTimer?.cancel();
    _startTime = null;

    emit(LocationState()); // Reset to initial state
  }

  void _onPauseTracking(PauseTracking event, Emitter<LocationState> emit) {
    emit(state.copyWith(isPaused: true));
  }

  Future<void> _onResumeTracking(
      ResumeTracking event, Emitter<LocationState> emit) async {
    emit(state.copyWith(isPaused: false));
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    _updateTimer?.cancel();
    return super.close();
  }
}