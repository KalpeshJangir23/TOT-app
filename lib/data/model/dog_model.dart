// dog_model.dart
import 'package:hive/hive.dart';

part 'dog_model.g.dart'; // This will be generated

@HiveType(typeId: 0)
class DogModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String breed_group; // Fixed typo (was breed_group)
  
  @HiveField(3)
  final String size;
  
  @HiveField(4)
  final String lifespan;
  
  @HiveField(5)
  final String origin;
  
  @HiveField(6)
  final String temperament;
  
  @HiveField(7)
  final List<String> colors;
  
  @HiveField(8)
  final String description;
  
  @HiveField(9)
  final String image;
  
  @HiveField(10)
  final DateTime savedAt;

  DogModel({
    required this.id,
    required this.name,
    required this.breed_group, // Fixed typo
    required this.size,
    required this.lifespan,
    required this.origin,
    required this.temperament,
    required this.colors,
    required this.description,
    required this.image,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  factory DogModel.fromJson(Map<String, dynamic> json) {
    return DogModel(
      id: json['id'],
      name: json['name'],
      breed_group: json['breed_group'], // Fixed typo
      size: json['size'],
      lifespan: json['lifespan'],
      origin: json['origin'],
      temperament: json['temperament'],
      colors: List<String>.from(json['colors']),
      description: json['description'],
      image: json['image'],
    );
  }

  DogModel copyWith({
    int? id,
    String? name,
    String? breedGroup, // Fixed typo
    String? size,
    String? lifespan,
    String? origin,
    String? temperament,
    List<String>? colors,
    String? description,
    String? image,
    DateTime? savedAt,
  }) {
    return DogModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breed_group: breedGroup ?? this.breed_group,
      size: size ?? this.size,
      lifespan: lifespan ?? this.lifespan,
      origin: origin ?? this.origin,
      temperament: temperament ?? this.temperament,
      colors: colors ?? this.colors,
      description: description ?? this.description,
      image: image ?? this.image,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
