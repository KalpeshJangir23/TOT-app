import 'package:latlong2/latlong.dart';
import 'package:tot_app/data/model/journey_model.dart';

class LocationState {
  final LatLng? currentPosition;
  final LatLng? source;
  final LatLng? destination;
  final List<LatLng> routeCoordinates;
  final bool isTracking;
  final bool isPaused;
  final String? error;
  final Journey? journey;
  final DateTime? startTime;
  final Duration duration;

  LocationState({
    this.currentPosition,
    this.source,
    this.destination,
    this.routeCoordinates = const [],
    this.isTracking = false,
    this.isPaused = false,
    this.error,
    this.journey,
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
    String? error,
    Journey? journey,
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
      error: error,
      journey: journey ?? this.journey,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
    );
  }
}
