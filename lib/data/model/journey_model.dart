import 'package:latlong2/latlong.dart';

class Journey {
  final LatLng source;
  final LatLng destination;
  final double distance;
  final Duration duration;

  Journey({
    required this.source,
    required this.destination,
    required this.distance,
    required this.duration,
  });
}
