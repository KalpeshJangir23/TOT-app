import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_state.dart';
import 'package:tot_app/data/model/dog_model.dart';
import 'package:tot_app/data/repositories/dog_repo.dart';

class DogScreenBloc extends Bloc<DogEvent, DogScreenState> {
  final DogRepo dogRepo;
  final Box<DogModel> _dogsBox = Hive.box<DogModel>('savedDogs');

  DogScreenBloc({required this.dogRepo}) : super(DogScreenInitial()) {
    on<FetchDogs>(_onFetchDogs);
    on<SaveDogDetails>(_onSaveDog);
    on<LoadSavedDogs>(_onLoadSavedDogs);
    on<RemoveDogDetails>(_onRemoveDog);
  }

  Future<void> _onFetchDogs(
    FetchDogs event,
    Emitter<DogScreenState> emit,
  ) async {
    try {
      emit(DogScreenLoading());
      final List<DogModel> dogs = await dogRepo.getDogs();
      final List<DogModel> savedDogs = _dogsBox.values.toList();
      if (!emit.isDone) {
        emit(DogScreenLoaded(dogs, savedDogs: savedDogs));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(DogScreenError('Failed to fetch dogs: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSaveDog(
    SaveDogDetails event,
    Emitter<DogScreenState> emit,
  ) async {
    try {
      await _dogsBox.put(event.dog.id, event.dog);

      if (state is DogScreenLoaded && !emit.isDone) {
        final currentState = state as DogScreenLoaded;
        final updatedSavedDogs = _dogsBox.values.toList();
        emit(DogScreenLoaded(
          currentState.dog_data,
          savedDogs: updatedSavedDogs,
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(DogScreenError('Failed to save dog: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadSavedDogs(
    LoadSavedDogs event,
    Emitter<DogScreenState> emit,
  ) async {
    try {
      final savedDogs = _dogsBox.values.toList();
      if (state is DogScreenLoaded && !emit.isDone) {
        final currentState = state as DogScreenLoaded;
        emit(DogScreenLoaded(
          currentState.dog_data,
          savedDogs: savedDogs,
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(DogScreenError('Failed to load saved dogs: ${e.toString()}'));
      }
    }
  }

  Future<void> _onRemoveDog(
    RemoveDogDetails event,
    Emitter<DogScreenState> emit,
  ) async {
    try {
      await _dogsBox.delete(event.dogId);

      if (state is DogScreenLoaded && !emit.isDone) {
        final currentState = state as DogScreenLoaded;
        final updatedSavedDogs = _dogsBox.values.toList();
        emit(DogScreenLoaded(
          currentState.dog_data,
          savedDogs: updatedSavedDogs,
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(DogScreenError('Failed to remove dog: ${e.toString()}'));
      }
    }
  }
}
