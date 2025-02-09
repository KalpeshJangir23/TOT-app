import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_state.dart';
import 'package:tot_app/constants/theme/app_theme.dart';
import 'package:tot_app/presentation/widgets/dog_card_widget.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh saved dogs when screen opens
    context.read<DogScreenBloc>().add(LoadSavedDogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Saved Dogs'),
      ),
      body: BlocBuilder<DogScreenBloc, DogScreenState>(
        builder: (context, state) {
          if (state is DogScreenLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }

          if (state is DogScreenLoaded) {
            final savedDogs = state.savedDogs;

            if (savedDogs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 64,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved dogs yet',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save some dogs to see them here!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: () async {
                context.read<DogScreenBloc>().add(LoadSavedDogs());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: savedDogs.length,
                itemBuilder: (context, index) {
                  final dog = savedDogs[index];
                  return Dismissible(
                    key: Key(dog.id.toString()),
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      context
                          .read<DogScreenBloc>()
                          .add(RemoveDogDetails(dog.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${dog.name} removed from saved dogs'),
                          backgroundColor: AppTheme.primaryColor,
                          action: SnackBarAction(
                            label: 'UNDO',
                            textColor: Colors.white,
                            onPressed: () {
                              context
                                  .read<DogScreenBloc>()
                                  .add(SaveDogDetails(dog));
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DogCard(
                        dog: dog,
                        isSaved: true,
                        onSavePressed: () {
                          context
                              .read<DogScreenBloc>()
                              .add(RemoveDogDetails(dog.id));
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state is DogScreenError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading saved dogs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red.shade400,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DogScreenBloc>().add(LoadSavedDogs());
                    },
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

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
