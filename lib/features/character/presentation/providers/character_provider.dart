import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/character_repository.dart';
import '../../../../core/network/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final characterRepositoryProvider = Provider(
  (ref) => CharacterRepository(ref.read(apiServiceProvider)),
);

final characterListProvider = FutureProvider.family((ref, int page) async {
  final repo = ref.read(characterRepositoryProvider);
  return repo.fetchCharacters(page);
});
