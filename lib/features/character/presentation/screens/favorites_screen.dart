import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:rick_morty_app/features/character/data/models/character_model.dart';
import 'package:rick_morty_app/features/character/data/services/character_merge_service.dart';
import 'package:rick_morty_app/features/character/presentation/providers/favorites_provider.dart';
import 'package:rick_morty_app/features/character/presentation/screens/character_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);

    final box = Hive.box('charactersBox');
    final characters = box.values.toList().cast<CharacterModel>();
    final mergeService = CharacterMergeService();

    final favCharacters =
        characters.where((c) => favIds.contains(c.id)).toList();

    if (favCharacters.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No Favorites yet",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: favCharacters.length,
        itemBuilder: (context, index) {
          final char = favCharacters[index];
          final mergedChar = mergeService.merge(char);

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CharacterDetailScreen(character: char),
                ),
              );
            },
            leading: Image.network(
              mergedChar.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(mergedChar.name),
            subtitle: Text("${mergedChar.species} - ${mergedChar.status}"),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                ref.read(favoritesProvider.notifier).toggle(char.id);
              },
            ),
          );
        },
      ),
    );
  }
}
