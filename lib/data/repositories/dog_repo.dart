import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tot_app/data/model/dog_model.dart';
import 'package:tot_app/services/api_services.dart';

class DogRepo {
  Future<List<DogModel>> getDogs() async {
    try {
      final http.Response response =
          await ApiService.getRequest('https://freetestapi.com/api/v1/dogs');
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Correctly map JSON to DogModel objects
        List<DogModel> got_data_fromApi = data
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
                image: dogJson['image']))
            .toList();

        return got_data_fromApi;
      } else {
        throw Exception('Failed to fetch dogs: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch dogs: $e');
      throw Exception('Failed to fetch dogs: $e');
    }
  }
}
