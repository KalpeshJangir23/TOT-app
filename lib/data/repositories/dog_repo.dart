import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tot_app/data/model/dog_model.dart';

class DogRepo {
  Future<List<DogModel>> getDogs({
    String? name,
    String? breedGroup,
    String? size,
    String? lifespan,
    String? origin,
    String? temperament,
    List<String>? colors,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {};
      if (name != null) queryParams['name'] = name;
      if (breedGroup != null) queryParams['breed_group'] = breedGroup;
      if (size != null) queryParams['size'] = size;
      if (lifespan != null) queryParams['lifespan'] = lifespan;
      if (origin != null) queryParams['origin'] = origin;
      if (temperament != null) queryParams['temperament'] = temperament;
      if (colors != null) queryParams['colors'] = colors.join(',');

      // Build URI with query parameters
      final uri = Uri.https('freetestapi.com', '/api/v1/dogs', queryParams);

      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((dogJson) => DogModel(
                  id: dogJson['id'],
                  name: dogJson['name'],
                  breed_group: dogJson['breed_group'],
                  size: dogJson['size'],
                  lifespan: dogJson['lifespan'],
                  origin: dogJson['origin'],
                  temperament: dogJson['temperament'],
                  colors: List<dynamic>.from(dogJson['colors']),
                  description: dogJson['description'],
                  image: dogJson['image'],
                ))
            .toList();
      } else {
        throw Exception('Failed to fetch dogs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch dogs: $e');
    }
  }
}
