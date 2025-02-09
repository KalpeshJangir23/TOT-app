import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_state.dart';
import 'package:tot_app/data/model/dog_model.dart';
import 'package:tot_app/data/repositories/dog_repo.dart';
import 'package:tot_app/presentation/save_screen.dart';
import 'package:tot_app/presentation/widgets/dog_card_widget.dart';

class DogHomeScreen extends StatefulWidget {
  const DogHomeScreen({super.key});

  @override
  _DogHomeScreenState createState() => _DogHomeScreenState();
}

class _DogHomeScreenState extends State<DogHomeScreen> {
  String searchQuery = '';
  List<DogModel> filteredDogs = [];
  final PageController _pageController = PageController(viewportFraction: 0.9);
  late DogScreenBloc _dogBloc;

  @override
  void initState() {
    super.initState();
    _dogBloc = DogScreenBloc(dogRepo: DogRepo())
      ..add(FetchDogs())
      ..add(LoadSavedDogs()); 
  }

  @override
  void dispose() {
    _dogBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _dogBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TOT app 🐶'),
          actions: [
            BlocBuilder<DogScreenBloc, DogScreenState>(
              builder: (context, state) {
                if (state is DogScreenLoaded) {
                  return Badge(
                    label: Text(state.savedDogs.length.toString()),
                    child: IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SaveScreen(),
                        ));
                      },
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SaveScreen(),
                    ));
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<DogScreenBloc, DogScreenState>(
                builder: (context, state) {
                  if (state is DogScreenLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is DogScreenError) {
                    return Center(
                      child: Text(
                        'Oops! Something went wrong 🙁\n${state.message}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.red),
                      ),
                    );
                  }
                  if (state is DogScreenLoaded) {
                    filteredDogs = state.dog_data.where((dog) {
                      return dog.name.toLowerCase().contains(searchQuery) ||
                          dog.breed_group.toLowerCase().contains(searchQuery) ||
                          dog.temperament.toLowerCase().contains(searchQuery);
                    }).toList();

                    return filteredDogs.isEmpty
                        ? Center(
                            child: Text(
                              'No Dogs Found 🐾',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )
                        : ListView.builder(
                            controller: _pageController,
                            itemCount: filteredDogs.length,
                            itemBuilder: (context, index) {
                              final dog = filteredDogs[index];
                              final isSaved = state.savedDogs
                                  .any((savedDog) => savedDog.id == dog.id);

                              return DogCard(
                                dog: dog,
                                isSaved: isSaved,
                                onSavePressed: () {
                                  if (isSaved) {
                                    context.read<DogScreenBloc>().add(
                                          RemoveDogDetails(dog.id),
                                        );
                                  } else {
                                    context.read<DogScreenBloc>().add(
                                          SaveDogDetails(dog),
                                        );
                                  }
                                },
                              );
                            },
                          );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
