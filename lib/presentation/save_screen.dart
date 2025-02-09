import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_bloc.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_bloc/dog_screen_state.dart';
import 'package:tot_app/presentation/widgets/dog_card_widget.dart';

class SaveScreen extends StatelessWidget {
  const SaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Save'),
          bottom: const TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 20.0, color: Colors.black),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            tabs: [
              Tab(text: 'Dogs'),
              Tab(text: 'Walks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DogsTab(),
            WalksTab(),
          ],
        ),
      ),
    );
  }
}

class DogsTab extends StatefulWidget {
  const DogsTab({super.key});

  @override
  State<DogsTab> createState() => _DogsTabState();
}

class _DogsTabState extends State<DogsTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DogScreenBloc, DogScreenState>(
      builder: (context, state) {
        if (state is DogScreenLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DogScreenLoaded) {
          final savedDogs = state.savedDogs;

          if (savedDogs.isEmpty) {
            return const Center(
              child: Text(
                'No saved dogs yet',
                style: TextStyle(fontSize: 24),
              ),
            );
          }

          return ListView.builder(
            itemCount: savedDogs.length,
            itemBuilder: (context, index) {
              final dog = savedDogs[index];
              return DogCard(
                dog: dog,
                isSaved: true,
                onSavePressed: () {
                  context.read<DogScreenBloc>().add(RemoveDogDetails(dog.id));
                },
              );
            },
          );
        }

        if (state is DogScreenError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class WalksTab extends StatelessWidget {
  const WalksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Save Walks',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
