import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rick_morty_app/features/character/data/models/character_model.dart';
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

  // Search & Filter state (bonus)
  final TextEditingController searchController = TextEditingController();
  String selectedStatus = 'All';
  String selectedSpecies = 'All';

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  List<CharacterModel> allCharacters = [];

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

    // Live search
    searchController.addListener(() => setState(() {}));
  }

  // Filtered list (client-side for bonus - works with your current provider)
  List<CharacterModel> get filteredCharacters {
    return allCharacters.where((char) {
      final merged = mergeService.merge(char);

      final matchesSearch = searchController.text.isEmpty ||
          merged.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase());

      final matchesStatus =
          selectedStatus == 'All' || merged.status == selectedStatus;
      final matchesSpecies =
          selectedSpecies == 'All' || merged.species == selectedSpecies;

      return matchesSearch && matchesStatus && matchesSpecies;
    }).toList();
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

  void _clearFilters() {
    searchController.clear();
    setState(() {
      selectedStatus = 'All';
      selectedSpecies = 'All';
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favs = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Characters")),
      body: Column(
        children: [
          // Search + Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Status Filter
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: ['All', 'Alive', 'Dead', 'Unknown']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedStatus = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Species Filter
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSpecies,
                    isExpanded: true,
                    items: [
                      'All',
                      'Human',
                      'Alien',
                      'Robot',
                      'Mythological Creature'
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null)
                        setState(() => selectedSpecies = value);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Clear Filters button
          if (searchController.text.isNotEmpty ||
              selectedStatus != 'All' ||
              selectedSpecies != 'All')
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),

          // Character List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filteredCharacters.length + 1,
              itemBuilder: (context, index) {
                if (index < filteredCharacters.length) {
                  final char = filteredCharacters[index];
                  final mergedChar = mergeService.merge(char);
                  final isFav = favs.contains(char.id);

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CharacterDetailScreen(character: char),
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
                    subtitle:
                        Text("${mergedChar.species} - ${mergedChar.status}"),
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
          ),
        ],
      ),
    );
  }
}
