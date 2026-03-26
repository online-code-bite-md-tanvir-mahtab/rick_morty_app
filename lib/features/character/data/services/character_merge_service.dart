import 'package:hive/hive.dart';
import '../models/character_model.dart';

class CharacterMergeService {
  final Box editsBox = Hive.box('editsBox');

  CharacterModel merge(CharacterModel apiChar) {
    final edited = editsBox.get(apiChar.id);

    if (edited != null && edited is CharacterModel) {
      return apiChar.copyWith(
        name: edited.name,
        status: edited.status,
        species: edited.species,
        type: edited.type,
        gender: edited.gender,
        origin: edited.origin,
        location: edited.location,
      );
    }

    return apiChar;
  }
}
