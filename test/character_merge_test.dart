import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

import 'package:rick_morty_app/features/character/data/models/character_model.dart';
import 'package:rick_morty_app/features/character/data/services/character_merge_service.dart';

void main() {
  late Box editsBox;
  late CharacterMergeService mergeService;

  setUp(() async {
    await setUpTestHive();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CharacterModelAdapter());
    }
    editsBox = await Hive.openBox('editsBox');

    mergeService = CharacterMergeService();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('should override API data with edited data', () {
    final apiChar = CharacterModel(
      id: 1,
      name: "Rick",
      status: "Alive",
      species: "Human",
      image: "",
      origin: '',
      location: '',
      episodeCount: 0,
    );

    final editedChar = apiChar.copyWith(name: "Edited Rick");

    editsBox.put(1, editedChar);

    final result = mergeService.merge(apiChar);

    expect(result.name, "Edited Rick");
  });

  test('should return API data if no edit exists', () {
    final apiChar = CharacterModel(
      id: 2,
      name: "Morty",
      status: "Alive",
      species: "Human",
      image: "",
      origin: '',
      location: '',
      episodeCount: 0,
    );

    final result = mergeService.merge(apiChar);

    expect(result.name, "Morty");
  });
}
