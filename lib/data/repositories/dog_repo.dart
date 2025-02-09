import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:tot_app/data/model/dog_model.dart';

class DogRepo {
  static const String savedDogsBoxName = 'savedDogs';
  late Box<DogModel> _savedDogsBox;
  List<DogModel> _cachedDogs = [];

  DogRepo() {
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(savedDogsBoxName)) {
      _savedDogsBox = await Hive.openBox<DogModel>(savedDogsBoxName);
    } else {
      _savedDogsBox = Hive.box<DogModel>(savedDogsBoxName);
    }
  }

  Future<List<DogModel>> getDogs() async {
    try {
      // Return cached data if available
      if (_cachedDogs.isNotEmpty) {
        return _cachedDogs;
      }

      final uri = Uri.parse('https://freetestapi.com/api/v1/dogs');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0', // Add user agent to prevent 403
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cachedDogs = data
            .map((dogJson) => DogModel(
                  id: dogJson['id'],
                  name: dogJson['name'] ?? '',
                  breed_group: dogJson['breed_group'] ?? '',
                  size: dogJson['size'] ?? '',
                  lifespan: dogJson['lifespan'] ?? '',
                  origin: dogJson['origin'] ?? '',
                  temperament: dogJson['temperament'] ?? '',
                  colors: List<String>.from(dogJson['colors'] ?? []),
                  description: dogJson['description'] ?? '',
                  image: dogJson['image'] ?? '',
                ))
            .toList();
        return _cachedDogs;
      } else {
        throw Exception('Failed to fetch dogs: ${response.statusCode}');
      }
    } catch (e) {
      // Return cached data if available, otherwise rethrow
      if (_cachedDogs.isNotEmpty) {
        return _cachedDogs;
      }
      throw Exception('Failed to fetch dogs: $e');
    }
  }

  Future<void> saveDog(DogModel dog) async {
    await _savedDogsBox.put(dog.id, dog);
  }

  Future<void> removeDog(int dogId) async {
    await _savedDogsBox.delete(dogId);
  }

  List<DogModel> getSavedDogs() {
    return _savedDogsBox.values.toList();
  }

  bool isDogSaved(int dogId) {
    return _savedDogsBox.containsKey(dogId);
  }
}
