class DogModel {
  final int id;
  final String name;
  final String breed_group;
  final String size;
  final String lifespan;
  final String origin;
  final String temperament;
  final List<dynamic> colors;
  final String description;
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
    required this.description,
    required this.image,
  });

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
