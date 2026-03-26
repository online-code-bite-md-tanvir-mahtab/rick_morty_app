import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/character_model.dart';

class EditCharacterScreen extends StatefulWidget {
  final CharacterModel character;

  const EditCharacterScreen({super.key, required this.character});

  @override
  State<EditCharacterScreen> createState() => _EditCharacterScreenState();
}

class _EditCharacterScreenState extends State<EditCharacterScreen> {
  late TextEditingController nameController;
  late TextEditingController statusController;
  late TextEditingController speciesController;
  late TextEditingController typeController;
  late TextEditingController genderController;
  late TextEditingController originController;
  late TextEditingController locationController;

  final box = Hive.box('editsBox'); // ← unchanged as you requested

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.character.name);
    statusController = TextEditingController(text: widget.character.status);
    speciesController = TextEditingController(text: widget.character.species);
    typeController = TextEditingController(text: widget.character.type ?? '');
    genderController =
        TextEditingController(text: widget.character.gender ?? '');
    originController = TextEditingController(text: widget.character.origin);
    locationController = TextEditingController(text: widget.character.location);
  }

  void save() {
    final edited = widget.character.copyWith(
      name: nameController.text,
      status: statusController.text,
      species: speciesController.text,
      type: typeController.text,
      gender: genderController.text,
      origin: originController.text,
      location: locationController.text,
    );

    box.put(widget.character.id, edited);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    statusController.dispose();
    speciesController.dispose();
    typeController.dispose();
    genderController.dispose();
    originController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Character")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Status')),
            TextField(
                controller: speciesController,
                decoration: const InputDecoration(labelText: 'Species')),
            TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type')),
            TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: 'Gender')),
            TextField(
                controller: originController,
                decoration: const InputDecoration(labelText: 'Origin name')),
            TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location name')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
