import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Assuming previous Bloc and Repo implementations
import 'package:tot_app/bloc/dog_screen_bloc.dart';
import 'package:tot_app/bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_screen_state.dart';
import 'package:tot_app/data/model/dog_model.dart';
import 'package:tot_app/data/repositories/dog_repo.dart';

class DogHomeScreen extends StatelessWidget {
  const DogHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DogScreenBloc(dogRepo: DogRepo())..add(FetchDogs()),
      child: Scaffold(
        backgroundColor: Colors.pink[50],
        appBar: AppBar(
          title: const Text('TOT app 🐶',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.pink[300],
          centerTitle: true,
        ),
        body: BlocBuilder<DogScreenBloc, DogScreenState>(
          builder: (context, state) {
            if (state is DogScreenLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.pink[300],
                ),
              );
            }
            if (state is DogScreenError) {
              return Center(
                child: Text(
                  'Oops! Something went wrong 🙁\n${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (state is DogScreenLoaded) {
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: state.dog_data.length,
                itemBuilder: (context, index) {
                  final dog = state.dog_data[index];
                  return _DogCard(dog: dog);
                },
              );
            }
            return const Center(child: Text('No Dogs Found 🐾'));
          },
        ),
      ),
    );
  }
}

class _DogCard extends StatelessWidget {
  final DogModel dog;

  const _DogCard({required this.dog});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDogDetails(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.pink[100]!, Colors.pink[50]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: dog.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dog.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[800],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        dog.breed_group,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.pink[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDogDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.pink[50],
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => ListView(
          controller: controller,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      dog.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow('Breed Group', dog.breed_group),
                  _buildDetailRow('Size', dog.size),
                  _buildDetailRow('Lifespan', dog.lifespan),
                  _buildDetailRow('Origin', dog.origin),
                  _buildDetailRow('Temperament', dog.temperament),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Colors:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[700],
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: dog.colors
                        .map((color) => Chip(
                              label: Text(color),
                              backgroundColor: Colors.pink[100],
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'About',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    dog.description,
                    style: TextStyle(color: Colors.pink[900]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pink[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.pink[900]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
