import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

abstract class LocationEvent {}

class StartTracking extends LocationEvent {
  final BuildContext context;
  StartTracking(this.context);
}

class UpdateCurrentPosition extends LocationEvent {
  final LatLng position;
  UpdateCurrentPosition(this.position);
}

class StopTracking extends LocationEvent {}

class ResetTracking extends LocationEvent {}

class PauseTracking extends LocationEvent {}

class ResumeTracking extends LocationEvent {}