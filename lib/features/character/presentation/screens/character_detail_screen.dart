import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:rick_morty_app/features/character/data/models/character_model.dart';
import 'package:rick_morty_app/features/character/data/services/character_merge_service.dart';
import 'package:rick_morty_app/features/character/presentation/providers/favorites_provider.dart';
import 'package:rick_morty_app/features/character/presentation/screens/edit_character_screen.dart';

class CharacterDetailScreen extends ConsumerStatefulWidget {
  final CharacterModel character;

  const CharacterDetailScreen({
    super.key,
    required this.character,
  });

  @override
  ConsumerState<CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen> {
  late CharacterModel displayedCharacter; // The merged character data
  late CharacterMergeService
      mergeService; // Service to merge API and local data

  // Access the editsBox
  late Box editsBox; // Make sure your Hive box is typed

  @override
  void initState() {
    super.initState();
    mergeService = CharacterMergeService();
    editsBox = Hive.box('editsBox'); // Initialize editsBox
    _loadDisplayedCharacter();
  }

  // This method will now use CharacterMergeService to get the latest state
  void _loadDisplayedCharacter() {
    // This merges the original character data with any local edits
    displayedCharacter = mergeService.merge(widget.character);
  }

  // Call this after any local edit or reset to refresh the UI
  void _refreshAfterEdit() {
    setState(() {
      _loadDisplayedCharacter(); // Reload the merged character
      // Also notify characterListProvider if you want changes to reflect on the list
      // ref.invalidate(characterListProvider(page)); // This would need the page number
      // A more robust solution might be to use a ChangeNotifierProvider or a stream
      // that the list listens to for updates on individual characters.
      // For now, refreshing the detail screen is the direct fix.
    });
  }

  // Function to reset local edits for this character
  void _resetToApiData() {
    editsBox.delete(widget.character.id); // Remove the local edit from Hive
    _refreshAfterEdit(); // Refresh UI to show original API data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Character data reset to API defaults!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite =
        ref.watch(favoritesProvider).contains(widget.character.id);

    // Check if this character has local edits
    final hasLocalEdits = editsBox.containsKey(widget.character.id);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Dark background color
      extendBodyBehindAppBar: true, // Allow content to go under app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          displayedCharacter.name, // Display character name in app bar
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true, // Center the title
        actions: [
          // Favorite Button
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggle(widget.character.id);
            },
          ),
          // Edit Button (re-integrated)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              // Pass the CURRENTLY displayedCharacter for editing
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditCharacterScreen(character: displayedCharacter),
                ),
              );

              // If an edit was made and saved, refresh the UI
              if (result == true) {
                _refreshAfterEdit();
              }
            },
          ),
          // Reset to API Data button (Bonus feature, added as an action)
          if (hasLocalEdits) // Only show if there are local edits
            IconButton(
              icon: const Icon(Icons.settings_backup_restore,
                  color: Colors.white), // A suitable icon for reset
              tooltip: 'Reset to API data',
              onPressed: _resetToApiData,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Character Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(displayedCharacter.image),
                  fit: BoxFit.cover,
                  // Handle image loading errors
                  onError: (exception, stacktrace) {
                    // You can log the error or provide a placeholder image
                    print('Error loading image: $exception');
                  },
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 60, // Adjust height as needed for the fade
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF1C1C1E)
                            .withOpacity(0.8), // Matches background
                        const Color(0xFF1C1C1E),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main info section - starts just below the image
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E), // Dark background for this section
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Character Name & Status (centered for visual hierarchy as per screenshot concept)
                  Center(
                    child: Text(
                      displayedCharacter.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getStatusColor(displayedCharacter.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        displayedCharacter.status,
                        style: TextStyle(
                          color: _getStatusColor(displayedCharacter.status),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Species & Type Row (re-integrating Type)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.st,
                    children: [
                      Expanded(
                        child: _buildInfoBlock(
                          'Species',
                          displayedCharacter.species ?? 'Unknown',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoBlock(
                          'Type',
                          displayedCharacter.type ?? "Unknown",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Gender info (separate as per screenshot's general layout for origin/location)
                  _buildNavigableInfoCard(
                    // Using the card style for consistency
                    context: context,
                    label: 'GENDER',
                    value: displayedCharacter.gender ?? 'Unknown',
                    icon: Icons.person, // A suitable icon for gender
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Gender: ${displayedCharacter.gender}')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Origin Section
                  _buildNavigableInfoCard(
                    context: context,
                    label: 'ORIGIN',
                    value: displayedCharacter.origin,
                    icon: Icons.public, // Earth icon
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Origin: ${displayedCharacter.origin}')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Known Location Section
                  _buildNavigableInfoCard(
                    context: context,
                    label: 'LAST KNOWN LOCATION',
                    value: displayedCharacter.location,
                    icon: Icons.location_on, // Location icon
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Location: ${displayedCharacter.location}')),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Episodes Section
                  Text(
                    'EPISODES (${displayedCharacter.episodeCount})',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // You might list actual episodes here, or navigate to an episodes list
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.greenAccent;
      case 'dead':
        return Colors.redAccent;
      case 'unknown':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Unknown' : value,
          maxLines: 2, // ✅ prevent overflow
          overflow: TextOverflow.ellipsis, // ✅ add ...
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigableInfoCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E), // Darker grey for cards
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Unknown' : value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
