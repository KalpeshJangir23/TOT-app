import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_state.dart';
import 'package:tot_app/constants/theme/app_theme.dart';
import 'package:tot_app/data/model/dog_model.dart';
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

  @override
  void initState() {
    super.initState();
    
    _fetchData();
  }

  void _fetchData() {
    final bloc = context.read<DogScreenBloc>();
    
    if (bloc.state is! DogScreenLoaded ||
        (bloc.state is DogScreenLoaded &&
            (bloc.state as DogScreenLoaded).dog_data.isEmpty)) {
      bloc.add(FetchDogs());
    }
    bloc.add(LoadSavedDogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOT app 🐶'),
        actions: [
          BlocBuilder<DogScreenBloc, DogScreenState>(
            builder: (context, state) {
              if (state is DogScreenLoaded) {
                return Badge(
                  label: Text(state.savedDogs.length.toString()),
                  child: IconButton(
                    icon: const Icon(Icons.bookmark),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SaveScreen(),
                        ),
                      );
                    },
                  ),
                );
              }
              return const IconButton(
                icon: Icon(Icons.bookmark_border),
                onPressed: null,
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
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                if (state is DogScreenError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Oops! Something went wrong 🙁',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DogScreenLoaded) {
                  if (state.dog_data.isEmpty) {
                    _fetchData(); 
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    );
                  }

                  
                  if (searchQuery.isNotEmpty) {
                    filteredDogs = state.dog_data.where((dog) {
                      final searchLower = searchQuery.toLowerCase();
                      return dog.name.toLowerCase().contains(searchLower) ||
                          dog.breed_group.toLowerCase().contains(searchLower) ||
                          dog.temperament.toLowerCase().contains(searchLower);
                    }).toList();
                  } else {
                    filteredDogs = state.dog_data;
                  }

                  if (filteredDogs.isEmpty && searchQuery.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppTheme.primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Dogs Found 🐾',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppTheme.primaryColor,
                    onRefresh: () async {
                      _fetchData();
                    },
                    child: ListView.builder(
                      controller: _pageController,
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredDogs.length,
                      itemBuilder: (context, index) {
                        final dog = filteredDogs[index];
                        final isSaved = state.savedDogs
                            .any((savedDog) => savedDog.id == dog.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: DogCard(
                            key: ValueKey(dog.id),
                            dog: dog,
                            isSaved: isSaved,
                            onSavePressed: () {
                              if (isSaved) {
                                context
                                    .read<DogScreenBloc>()
                                    .add(RemoveDogDetails(dog.id));
                              } else {
                                context
                                    .read<DogScreenBloc>()
                                    .add(SaveDogDetails(dog));
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
