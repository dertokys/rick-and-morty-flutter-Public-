class Character {
  final int id;
  final String name;
  final String status; 
  final String species;
  final String image; 
  final String location; 

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.location,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      species: json['species'] as String? ?? '',
      image: json['image'] as String? ?? '',
      location: (json['location']?['name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'species': species,
        'image': image,
        'location': {'name': location},
      };
}