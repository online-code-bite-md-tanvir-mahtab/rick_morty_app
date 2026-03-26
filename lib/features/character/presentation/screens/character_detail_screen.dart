import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/character_model.dart';
import 'edit_character_screen.dart';

class CharacterDetailScreen extends StatefulWidget {
  final CharacterModel character;

  const CharacterDetailScreen({
    super.key,
    required this.character,
  });

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late CharacterModel displayedCharacter;
  final editsBox = Hive.box('editsBox');

  @override
  void initState() {
    super.initState();
    _loadDisplayedCharacter();
  }

  void _loadDisplayedCharacter() {
    // Merge: if user edited this character, use edited version, else use original API data
    final edited = editsBox.get(widget.character.id);
    displayedCharacter = edited ?? widget.character;
  }

  void _refreshAfterEdit() {
    setState(() {
      _loadDisplayedCharacter();
    });
  }

  void _resetToApiData() {
    editsBox.delete(widget.character.id); // ← removes the local edit

    _refreshAfterEdit(); // refresh to show original data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(displayedCharacter.name),
        actions: [
          IconButton(
            onPressed: () {
              _resetToApiData();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditCharacterScreen(character: displayedCharacter),
                ),
              );

              if (result == true) {
                _refreshAfterEdit();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Large Image
            Image.network(
              displayedCharacter.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 100),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status with color
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(displayedCharacter.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        displayedCharacter.status,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _infoRow('Species', displayedCharacter.species),
                  _infoRow('Type', displayedCharacter.type ?? 'N/A'),
                  _infoRow('Gender', displayedCharacter.gender ?? 'N/A'),
                  _infoRow('Origin', displayedCharacter.origin),
                  _infoRow('Last known location', displayedCharacter.location),
                  const SizedBox(height: 16),

                  // Episodes
                  Text(
                    'EPISODES (${displayedCharacter.episodeCount})',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
