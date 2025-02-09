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

// In dog_screen_event.dart
final class SaveDogDetails extends DogEvent {
  final DogModel dog; // Changed from List<DogModel>
  SaveDogDetails(this.dog);
}
final class RemoveDogDetails extends DogEvent {
  final int dogId;
  RemoveDogDetails(this.dogId);
}


final class LoadSavedDogs extends DogEvent {}
