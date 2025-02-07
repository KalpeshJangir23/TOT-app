import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tot_app/bloc/dog_screen_bloc.dart';
import 'package:tot_app/bloc/dog_screen_event.dart';
import 'package:tot_app/bloc/dog_screen_state.dart';
import 'package:tot_app/constants/theme/app_theme.dart';
import 'package:tot_app/data/model/dog_model.dart';
import 'package:tot_app/data/repositories/dog_repo.dart';

class DogHomeScreen extends StatefulWidget {
  const DogHomeScreen({super.key});

  @override
  _DogHomeScreenState createState() => _DogHomeScreenState();
}

class _DogHomeScreenState extends State<DogHomeScreen> {
  String searchQuery = '';
  List<DogModel> filteredDogs = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DogScreenBloc(dogRepo: DogRepo())..add(FetchDogs()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pawsome 🐶'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // Handle favorites
              },
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // Handle saved
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
                          dog.breed_group
                              .toLowerCase()
                              .contains(searchQuery) ||
                          dog.temperament
                              .toLowerCase()
                              .contains(searchQuery);
                    }).toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredDogs.length,
                      itemBuilder: (context, index) {
                        return _DogCard(dog: filteredDogs[index]);
                      },
                    );
                  }
                  return Center(
                    child: Text(
                      'No Dogs Found 🐾',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DogCard extends StatefulWidget {
  final DogModel dog;
  const _DogCard({required this.dog});

  @override
  State<_DogCard> createState() => _DogCardState();
}

class _DogCardState extends State<_DogCard> {
  bool isLiked = false;
  bool isSaved = false;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Adjust the width as needed
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Basic Info Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: widget.dog.image,
                    height: 300, // Increased image height
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.pets, size: 50),
                    ),
                  ),
                ),
                // Action Buttons
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        onPressed: () => setState(() => isLiked = !isLiked),
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? AppTheme.primaryColor : Colors.white,
                        onPressed: () => setState(() => isSaved = !isSaved),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Dog Information Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Breed Group
                  Text(
                    widget.dog.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    widget.dog.breed_group,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Quick Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoChip(icon: Icons.straighten, value: widget.dog.size),
                      _InfoChip(
                          icon: Icons.schedule, value: widget.dog.lifespan),
                      _InfoChip(icon: Icons.place, value: widget.dog.origin),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Temperament preview
                  Text(
                    'Temperament: ${widget.dog.temperament.split(',').take(2).join(',')}...',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Show More Button
                  TextButton(
                    onPressed: () => setState(() => isExpanded = !isExpanded),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isExpanded ? 'Show Less' : 'Show More'),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  // Expandable Content
                  if (isExpanded) ...[
                    const Divider(),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dog.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Full Temperament',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dog.temperament,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    final colorMap = {
      'black': Colors.black,
      'white': Colors.white,
      'brown': Colors.brown,
      'gold': Colors.amber,
      'gray': Colors.grey,
    };
    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: color,
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}
