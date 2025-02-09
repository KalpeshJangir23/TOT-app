import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteRepository {
  Future<RouteResponse> getRoute(List<LatLng> coordinates) async {
    // Ensure coordinates are non-null and valid
    if (coordinates.isEmpty) {
      throw Exception('Coordinates list cannot be empty');
    }

    final coordString = coordinates
        .map((c) => '${c.longitude.toString()},${c.latitude.toString()}')
        .join(';');

    try {
      final response = await http.get(Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/$coordString?overview=full'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['routes'] == null || jsonResponse['routes'].isEmpty) {
          throw Exception('No route found');
        }
        return RouteResponse.fromJson(jsonResponse);
      }
      throw Exception('Failed to load route: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to process route request: $e');
    }
  }
}

class RouteResponse {
  final List<LatLng> points;
  final double distance;

  RouteResponse({required this.points, required this.distance});

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    try {
      final geometry = json['routes'][0]['geometry'] as String;
      final distance = (json['routes'][0]['distance'] as num).toDouble() /
          1000; // Convert to km

      final polylinePoints = PolylinePoints();
      final List<PointLatLng> decodedPoints =
          polylinePoints.decodePolyline(geometry);

      final List<LatLng> latLngList = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      return RouteResponse(
        points: latLngList,
        distance: distance,
      );
    } catch (e) {
      throw Exception('Failed to parse route response: $e');
    }
  }
}

class LocationRepository {
  Stream<LatLng> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((Position position) => LatLng(
              position.latitude,
              position.longitude,
            ));
  }
}
