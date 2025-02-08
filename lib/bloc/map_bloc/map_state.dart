
import 'package:latlong2/latlong.dart';
import 'package:tot_app/data/model/journey_model.dart';

class LocationState {
  final LatLng? currentPosition;
  final LatLng? source;
  final LatLng? destination;
  final List<LatLng> routeCoordinates;
  final bool isTracking;
  final bool isPaused;
  final Journey? journey;
  final String? error;
  final DateTime? startTime;
  final Duration duration;

  LocationState({
    this.currentPosition,
    this.source,
    this.destination,
    this.routeCoordinates = const [],
    this.isTracking = false,
    this.isPaused = false,
    this.journey,
    this.error,
    this.startTime,
    this.duration = const Duration(),
  });

  LocationState copyWith({
    LatLng? currentPosition,
    LatLng? source,
    LatLng? destination,
    List<LatLng>? routeCoordinates,
    bool? isTracking,
    bool? isPaused,
    Journey? journey,
    String? error,
    DateTime? startTime,
    Duration? duration,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      isTracking: isTracking ?? this.isTracking,
      isPaused: isPaused ?? this.isPaused,
      journey: journey ?? this.journey,
      error: error,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
    );
  }
}