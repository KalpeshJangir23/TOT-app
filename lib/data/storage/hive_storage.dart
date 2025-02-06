import 'package:hive_flutter/hive_flutter.dart';
import 'package:tot_app/data/model/dog_model.dart';

class HiveStorageService {
  final Box<DogModel> dogBox = Hive.box<DogModel>('dogs');

  Future<void> saveDog(DogModel dog) async {
    await dogBox.put(dog.id, dog);
  }

  List<DogModel> getSavedDogs() {
    return dogBox.values.toList();
  }
}
