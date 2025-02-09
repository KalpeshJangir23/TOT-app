import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_state.dart';
import 'package:tot_app/data/model/dog_model.dart';
import 'package:tot_app/data/repositories/dog_repo.dart';

class DogScreenBloc extends Bloc<DogEvent, DogScreenState> {
  final DogRepo dogRepo;

  DogScreenBloc({required this.dogRepo}) : super(DogScreenInitial()) {
    on<FetchDogs>(_onFetchDogs);
    on<SaveDogDetails>(_onSaveDog);
    on<LoadSavedDogs>(_onLoadSavedDogs);
    on<RemoveDogDetails>(_onRemoveDog);
  }

  Future<void> _onFetchDogs(
      FetchDogs event, Emitter<DogScreenState> emit) async {
    try {
      emit(DogScreenLoading());
      final List<DogModel> dogs = await dogRepo.getDogs();
      final List<DogModel> savedDogs = dogRepo.getSavedDogs();
      emit(DogScreenLoaded(dogs, savedDogs: savedDogs));
    } catch (e) {
      emit(DogScreenError('Failed to fetch dogs: ${e.toString()}'));
    }
  }

  Future<void> _onSaveDog(
      SaveDogDetails event, Emitter<DogScreenState> emit) async {
    try {
      await dogRepo.saveDog(event.dog);
      if (state is DogScreenLoaded) {
        final currentState = state as DogScreenLoaded;
        final updatedSavedDogs = dogRepo.getSavedDogs();
        emit(DogScreenLoaded(currentState.dog_data,
            savedDogs: updatedSavedDogs));
      }
    } catch (e) {
      emit(DogScreenError('Failed to save dog: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSavedDogs(
      LoadSavedDogs event, Emitter<DogScreenState> emit) async {
    try {
      final savedDogs = dogRepo.getSavedDogs();
      emit(DogScreenLoaded([], savedDogs: savedDogs));
    } catch (e) {
      emit(DogScreenError('Failed to load saved dogs: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveDog(
      RemoveDogDetails event, Emitter<DogScreenState> emit) async {
    try {
      await dogRepo.removeDog(event.dogId);
      if (state is DogScreenLoaded) {
        final currentState = state as DogScreenLoaded;
        final updatedSavedDogs = dogRepo.getSavedDogs();
        emit(DogScreenLoaded(currentState.dog_data,
            savedDogs: updatedSavedDogs));
      }
    } catch (e) {
      emit(DogScreenError('Failed to remove dog: ${e.toString()}'));
    }
  }
}
