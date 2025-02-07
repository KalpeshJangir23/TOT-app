import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tot_app/bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_screen_state.dart';
import 'package:tot_app/data/model/dog_model.dart';
import 'package:tot_app/data/repositories/dog_repo.dart';

class DogScreenBloc extends Bloc<DogEvent, DogScreenState> {
  final DogRepo dogRepo;

  DogScreenBloc({required this.dogRepo}) : super(DogScreenInitial()) {
    // Event handlers
    on<FetchDogs>(_onFetchDogs);
  }

  Future<void> _onFetchDogs(
      FetchDogs event, Emitter<DogScreenState> emit) async {
    try {
      emit(DogScreenLoading());

      final List<DogModel> dogs = await dogRepo.getDogs();

      emit(DogScreenLoaded(dogs));
    } catch (e) {
      emit(DogScreenError('Failed to fetch dogs: ${e.toString()}'));
    }
  }

  
}
