import 'package:tot_app/data/model/dog_model.dart';

abstract class DogEvent {}

final class FetchDogs extends DogEvent {}

class SearchDogs extends DogEvent {
  final String? name;
  final String? breedGroup;
  final String? size;
  final String? lifespan;
  final String? origin;
  final String? temperament;
  final List<String>? colors;

  SearchDogs({
    this.name,
    this.breedGroup,
    this.size,
    this.lifespan,
    this.origin,
    this.temperament,
    this.colors,
  });
}

final class SaveDogDetails extends DogEvent {
  final List<DogModel> dog;
  SaveDogDetails(this.dog);
}

final class LoadSavedDogs extends DogEvent {}
