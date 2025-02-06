import 'package:tot_app/data/model/dog_model.dart';

abstract class DogEvent {}

final class FetchDogs extends DogEvent {}

final class SaveDogDetails extends DogEvent {
  final List<DogModel> dog;
  SaveDogDetails(this.dog);
}

final class LoadSavedDogs extends DogEvent {}
