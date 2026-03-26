import 'package:hive/hive.dart';
import '../models/character_model.dart';
import '../../../../core/network/api_service.dart';

class CharacterRepository {
  final ApiService apiService;

  CharacterRepository(this.apiService);

  Future<List<CharacterModel>> fetchCharacters(int page) async {
    try {
      final response = await apiService.getCharacters(page);

      List data = response.data['results'];

      final characters = data.map((e) => CharacterModel.fromJson(e)).toList();

      // cache to Hive
      final box = Hive.box('charactersBox');
      for (var char in characters) {
        box.put(char.id, char);
      }

      return characters;
    } catch (e) {
      // fallback to cache
      final box = Hive.box('charactersBox');
      return box.values.cast<CharacterModel>().toList();
    }
  }
}
