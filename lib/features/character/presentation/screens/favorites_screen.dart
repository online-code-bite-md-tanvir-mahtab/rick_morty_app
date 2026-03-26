import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:rick_morty_app/features/character/data/services/character_merge_service.dart';
import 'package:rick_morty_app/features/character/presentation/providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);

    final box = Hive.box('charactersBox');
    final characters = box.values.toList();
    final mergeService = CharacterMergeService();

    final favCharacters =
        characters.where((c) => favIds.contains(c.id)).toList();

    if (favCharacters.isEmpty) {
      return const Center(child: Text("No Favorites"));
    }

    return ListView.builder(
      itemCount: favCharacters.length,
      itemBuilder: (context, index) {
        final char = favCharacters[index];
        final marged = mergeService.merge(char);

        return ListTile(title: Text(marged.name));
      },
    );
  }
}
