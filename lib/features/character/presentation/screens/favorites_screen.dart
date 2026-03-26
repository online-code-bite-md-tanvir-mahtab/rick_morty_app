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

    // It's generally better to open the box once, e.g., in main or a repository.
    // However, for this context, accessing it directly is fine.
    final box = Hive.box('charactersBox'); // Ensure type safety for the box
    final CharacterMergeService mergeService = CharacterMergeService();

    // Retrieve all characters from Hive and filter for favorites
    // Note: This approach assumes all potentially favorite characters are already
    // stored in the 'charactersBox'. If a character is favorited but not yet
    // loaded into 'charactersBox' (e.g., in a truly offline-first scenario where
    // only loaded characters are cached), it won't appear here.
    final favCharacters =
        box.values.where((character) => favIds.contains(character.id)).toList();

    return Scaffold(
      backgroundColor: Colors.black, // Consistent dark background
      appBar: AppBar(
        title: const Text(
          "Favorites",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: favCharacters.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: Colors.grey,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Favorites Yet",
                    style: TextStyle(fontSize: 22, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Add characters to your favorites from the list!",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              // Changed to GridView to match the list screen style
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Consistent with CharacterListScreen
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7, // Consistent with CharacterListScreen
              ),
              itemCount: favCharacters.length,
              itemBuilder: (context, index) {
                final char = favCharacters[index];
                final mergedChar = mergeService.merge(char);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CharacterDetailScreen(character: char),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.grey[850], // Dark card background
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Stack(
                            // Use Stack to overlay the favorite icon
                            children: [
                              Image.network(
                                mergedChar.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                              Positioned(
                                // Position the favorite icon
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.favorite,
                                      color: Colors.red),
                                  onPressed: () {
                                    ref
                                        .read(favoritesProvider.notifier)
                                        .toggle(char.id);
                                  },
                                  padding:
                                      EdgeInsets.zero, // Remove extra padding
                                  constraints:
                                      const BoxConstraints(), // Remove default constraints
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mergedChar.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mergedChar.status,
                                  style: TextStyle(
                                    color: mergedChar.status == 'Alive'
                                        ? Colors.greenAccent
                                        : mergedChar.status == 'Dead'
                                            ? Colors.redAccent
                                            : Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
