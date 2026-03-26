import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rick_morty_app/features/character/data/services/character_merge_service.dart';
import 'package:rick_morty_app/features/character/presentation/providers/character_provider.dart';
import 'package:rick_morty_app/features/character/presentation/providers/favorites_provider.dart';
import 'package:rick_morty_app/features/character/presentation/screens/character_detail_screen.dart';

class CharacterListScreen extends ConsumerStatefulWidget {
  const CharacterListScreen({super.key});

  @override
  ConsumerState<CharacterListScreen> createState() =>
      _CharacterListScreenState();
}

class _CharacterListScreenState extends ConsumerState<CharacterListScreen> {
  final ScrollController _scrollController = ScrollController();
  final mergeService = CharacterMergeService();

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  List allCharacters = [];

  @override
  void initState() {
    super.initState();

    loadData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        loadData();
      }
    });
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final data = await ref.read(characterListProvider(page).future);

      if (data.isEmpty) {
        hasMore = false;
      } else {
        page++;
        allCharacters.addAll(data);
      }
    } catch (e) {
      hasMore = false;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Characters")),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: allCharacters.length + 1,
        itemBuilder: (context, index) {
          if (index < allCharacters.length) {
            final char = allCharacters[index];
            final mergedChar = mergeService.merge(char);
            final favs = ref.watch(favoritesProvider);
            final isFav = favs.contains(char.id);
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CharacterDetailScreen(character: char),
                  ),
                );
              },
              leading: Image.network(mergedChar.image),
              title: Text(mergedChar.name),
              subtitle: Text("${mergedChar.species} - ${mergedChar.status}"),
              trailing: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggle(char.id);
                },
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("No more data"),
              ),
            );
          }
        },
      ),
    );
  }
}
