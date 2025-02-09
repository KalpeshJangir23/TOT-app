import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class RideEvent {}

class StartRide extends RideEvent {}

class StopRide extends RideEvent {}

class MapCreated extends RideEvent {
  final GoogleMapController controller;
  MapCreated(this.controller);
}
