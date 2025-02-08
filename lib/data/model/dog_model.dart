import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class DogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String breed_group;

  @HiveField(3)
  final String size;

  @HiveField(4)
  final String lifespan;

  @HiveField(5)
  final String origin;

  @HiveField(6)
  final String temperament;

  @HiveField(7)
  final List<dynamic> colors;

  @HiveField(8)
  final DateTime savedAt;

  @HiveField(9)
  final String description;

  @HiveField(10)
  final String image;


  DogModel({
    required this.id,
    required this.name,
    required this.breed_group,
    required this.size,
    required this.lifespan,
    required this.origin,
    required this.temperament,
    required this.colors,
    required this.image,
    required this.description,
    DateTime? savedAt,
  }) : this.savedAt = savedAt ?? DateTime.now();


  factory DogModel.fromJson(Map<String, dynamic> json) {
    return DogModel(
      id: json['id'],
      name: json['name'],
      breed_group: json['breed_group'],
      size: json['size'],
      lifespan: json['lifespan'],
      origin: json['origin'],
      temperament: json['temperament'],
      colors: List<String>.from(json['colors']),
      description: json['description'],
      image: json['image'],
    );
  }
}
