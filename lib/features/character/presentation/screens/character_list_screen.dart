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
  final CharacterMergeService mergeService = CharacterMergeService();

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  List<CharacterModel> allCharacters = [];

  // Search & Filter state
  final TextEditingController searchController = TextEditingController();
  String _selectedStatus = 'All'; // Changed to _selectedStatus
  String _selectedSpecies = 'All'; // Changed to _selectedSpecies
  bool _isSearching = false; // To control search bar visibility

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
    // Listener for live search and filter application
    searchController.addListener(_applyFiltersAndRefreshList);
  }

  // A method to apply filters and refresh the list without reloading all data
  void _applyFiltersAndRefreshList() {
    setState(() {}); // Re-evaluate filteredCharacters getter
  }

  // Filtered list (client-side for bonus)
  List<CharacterModel> get filteredCharacters {
    return allCharacters.where((char) {
      final merged = mergeService.merge(char);

      final matchesSearch = searchController.text.isEmpty ||
          merged.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase());

      final matchesStatus =
          _selectedStatus == 'All' || merged.status == _selectedStatus;
      final matchesSpecies =
          _selectedSpecies == 'All' || merged.species == _selectedSpecies;

      return matchesSearch && matchesStatus && matchesSpecies;
    }).toList();
  }

  Future<void> loadData() async {
    if (isLoading || !hasMore) return;

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
      print("Error loading characters: $e");
      hasMore = false;
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load more characters: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearFilters() {
    searchController.clear();
    setState(() {
      _selectedStatus = 'All';
      _selectedSpecies = 'All';
    });
    Navigator.pop(context); // Close the filter sheet
  }

  // Function to show the filter bottom sheet
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take full height if needed
      backgroundColor: Colors.transparent, // For custom rounded corners
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage state within the bottom sheet
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height *
                  0.7, // 70% of screen height
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E), // Dark background for the sheet
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle for dragging the sheet
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Filter Characters',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Status Filter
                    _buildDropdownField(
                      'Status',
                      _selectedStatus,
                      ['All', 'Alive', 'Dead', 'Unknown'],
                      (value) {
                        setModalState(() => _selectedStatus = value!);
                        _applyFiltersAndRefreshList();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Species Filter
                    _buildDropdownField(
                      'Species',
                      _selectedSpecies,
                      [
                        'All',
                        'Human',
                        'Alien',
                        'Mythological Creature',
                        'Robot',
                        'Poopybutthole',
                        'Humanoid',
                        'Animal',
                        'Cronenberg',
                        'Disease',
                        'Unknown'
                      ],
                      (value) {
                        setModalState(() => _selectedSpecies = value!);
                        _applyFiltersAndRefreshList();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Clear Filters button
                    if (searchController.text.isNotEmpty ||
                        _selectedStatus != 'All' ||
                        _selectedSpecies != 'All')
                      ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear, color: Colors.white),
                        label: const Text(
                          'Clear Filters',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Search characters...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      searchController.clear();
                      setState(() => _isSearching = false);
                    },
                  ),
                ),
              )
            : const Text(
                "Characters",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(_isSearching ? Icons.search_off : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  searchController.clear(); // Clear search when closing
                }
              });
            },
          ),
          // Filter Icon
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
          // Info Icon
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Info button pressed!')),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body:
          // Handle initial loading state
          allCharacters.isEmpty &&
                  isLoading &&
                  searchController.text.isEmpty &&
                  _selectedStatus == 'All' &&
                  _selectedSpecies == 'All'
              ? const Center(child: CircularProgressIndicator())
              :
              // Handle no data / empty state
              filteredCharacters.isEmpty && !isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sentiment_dissatisfied,
                              size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text("No characters found matching your criteria!",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          if (searchController.text.isNotEmpty ||
                              _selectedStatus != 'All' ||
                              _selectedSpecies != 'All')
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear,
                                    color: Colors.purple),
                                label: const Text(
                                  'Clear Search & Filters',
                                  style: TextStyle(
                                      color: Colors.purple, fontSize: 16),
                                ),
                              ),
                            )
                        ],
                      ),
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: filteredCharacters.length +
                          (hasMore &&
                                  searchController.text.isEmpty &&
                                  _selectedStatus == 'All' &&
                                  _selectedSpecies == 'All'
                              ? 1
                              : 0), // Only show loading indicator if not actively filtering/searching
                      itemBuilder: (context, index) {
                        if (index == filteredCharacters.length) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.purple));
                        }

                        final char = filteredCharacters[index];
                        final mergedChar = mergeService.merge(char);
                        final isFav = favs.contains(char.id);

                        return GestureDetector(
                          onTap: () async {
                            // Navigating to detail screen
                            // Await result to know if character was edited to refresh
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CharacterDetailScreen(character: char),
                              ),
                            );
                            // After returning from detail screen, refresh the list
                            // This ensures local edits on this character are reflected
                            _refreshCharacterInList(char.id);
                          },
                          child: Card(
                            color: Colors.grey[850],
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Image.network(
                                    mergedChar.image,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        // Optional: Favorite icon overlay (can be added if desired)
                                        // Positioned(
                                        //   top: 0,
                                        //   right: 0,
                                        //   child: IconButton(
                                        //     icon: Icon(
                                        //       isFav ? Icons.favorite : Icons.favorite_border,
                                        //       color: Colors.red,
                                        //       size: 20,
                                        //     ),
                                        //     onPressed: () {
                                        //       ref.read(favoritesProvider.notifier).toggle(char.id);
                                        //     },
                                        //     padding: EdgeInsets.zero,
                                        //     constraints: BoxConstraints(),
                                        //   ),
                                        // ),
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

  // Helper widget for consistent DropdownButton styling (reused from EditCharacterScreen)
  Widget _buildDropdownField(String labelText, String? currentValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),
      isEmpty:
          currentValue == null || currentValue == 'All' || currentValue.isEmpty,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue == 'All' || currentValue!.isEmpty
              ? null
              : currentValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF2C2C2E),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            onChanged(newValue);
          },
        ),
      ),
    );
  }

  // Refreshes a single character's data in the allCharacters list
  // This is a more targeted approach than re-fetching all data, especially for edits.
  void _refreshCharacterInList(int characterId) {
    final int index =
        allCharacters.indexWhere((char) => char.id == characterId);
    if (index != -1) {
      // Re-merge the character at this index to reflect any new edits
      // This assumes CharacterMergeService can retrieve the latest state for char.
      allCharacters[index] = mergeService.merge(allCharacters[index]);
      setState(() {}); // Trigger a rebuild to update the specific card
    }
  }
}
