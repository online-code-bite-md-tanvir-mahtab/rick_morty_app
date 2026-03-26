import 'package:hive/hive.dart';

part 'character_model.g.dart';

@HiveType(typeId: 0)
class CharacterModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final String species;

  @HiveField(4)
  final String? type;

  @HiveField(5)
  final String? gender;

  @HiveField(6)
  final String image;

  @HiveField(7)
  final String origin;

  @HiveField(8)
  final String location;

  @HiveField(9) // ← NEW
  final int episodeCount;

  CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    this.type,
    this.gender,
    required this.image,
    required this.origin,
    required this.location,
    required this.episodeCount,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String?,
      image: json['image'] as String,
      origin: (json['origin'] as Map<String, dynamic>?)?['name'] as String? ??
          'Unknown',
      location:
          (json['location'] as Map<String, dynamic>?)?['name'] as String? ??
              'Unknown',
      episodeCount: (json['episode'] as List<dynamic>?)?.length ?? 0,
    );
  }

  CharacterModel copyWith({
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
    String? origin,
    String? location,
    int? episodeCount,
  }) {
    return CharacterModel(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      species: species ?? this.species,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      image: image,
      origin: origin ?? this.origin,
      location: location ?? this.location,
      episodeCount: episodeCount ?? this.episodeCount,
    );
  }
}
