import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tot_app/data/model/journey_model.dart';

class OsrmRepository {
  Future<Journey> getRouteDetails(LatLng start, LatLng end) async {
    final response = await http.get(
      Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distance = data['routes'][0]['distance'] / 1000;
      final duration = Duration(seconds: data['routes'][0]['duration'].round());

      return Journey(
        source: start,
        destination: end,
        distance: distance,
        duration: duration,
      );
    } else {
      throw Exception('Failed to load route details');
    }
  }
}
