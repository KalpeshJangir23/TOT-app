import 'package:tot_app/data/model/dog_model.dart';

abstract class DogScreenState {}

final class DogScreenInitial extends DogScreenState {}

final class DogScreenLoading extends DogScreenState {}

final class DogScreenLoaded extends DogScreenState {
  final List<DogModel> dog_data;
  DogScreenLoaded(this.dog_data);
}

final class DogScreenError extends DogScreenState {
  final String message;
  DogScreenError(this.message);
}
