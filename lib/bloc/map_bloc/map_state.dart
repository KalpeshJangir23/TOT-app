import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class RideState {}

class RideInitial extends RideState {}

class RidePreparation extends RideState {}

class RideError extends RideState {
  final String message;
  RideError(this.message);
}

class RideInProgress extends RideState {
  final Polyline polyline;
  final Duration duration;
  final double distance;
  final LatLng? startPosition;
  final LatLng? currentPosition;

  RideInProgress({
    required this.polyline,
    required this.duration,
    required this.distance,
    this.startPosition,
    this.currentPosition,
  });
}
