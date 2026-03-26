import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/character_model.dart'; // Make sure CharacterModel is Hive-compatible (e.g., has HiveType annotation)

class EditCharacterScreen extends StatefulWidget {
  final CharacterModel character;

  const EditCharacterScreen({super.key, required this.character});

  @override
  State<EditCharacterScreen> createState() => _EditCharacterScreenState();
}

class _EditCharacterScreenState extends State<EditCharacterScreen> {
  late TextEditingController nameController;
  late TextEditingController
      statusController; // Consider making this a Dropdown
  late TextEditingController
      speciesController; // Consider making this a Dropdown
  late TextEditingController typeController;
  late TextEditingController
      genderController; // Consider making this a Dropdown
  late TextEditingController originController;
  late TextEditingController locationController;

  late Box editsBox; // Make sure your Hive box is typed

  // For Dropdown examples (if you choose to implement them)
  String? _selectedStatus;
  String? _selectedSpecies;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    editsBox = Hive.box('editsBox'); // Initialize editsBox

    nameController = TextEditingController(text: widget.character.name);
    statusController = TextEditingController(text: widget.character.status);
    speciesController = TextEditingController(text: widget.character.species);
    typeController = TextEditingController(text: widget.character.type ?? '');
    genderController =
        TextEditingController(text: widget.character.gender ?? '');
    originController = TextEditingController(text: widget.character.origin);
    locationController = TextEditingController(text: widget.character.location);

    // Initialize selected values for dropdowns if you use them
    _selectedStatus = widget.character.status;
    _selectedSpecies = widget.character.species;
    _selectedGender = widget.character.gender;
  }

  void save() {
    final edited = widget.character.copyWith(
      name: nameController.text.trim(),
      status: _selectedStatus ??
          statusController.text.trim(), // Use dropdown value if available
      species: _selectedSpecies ??
          speciesController.text.trim(), // Use dropdown value if available
      type: typeController.text.trim(),
      gender: _selectedGender ??
          genderController.text.trim(), // Use dropdown value if available
      origin: originController.text.trim(),
      location: locationController.text.trim(),
    );

    editsBox.put(widget.character.id, edited);

    // Notify the previous screen (CharacterDetailScreen) that an edit was made
    Navigator.pop(context, true); // Pass true to indicate a successful save
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
      backgroundColor: const Color(0xFF1C1C1E), // Dark background color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close,
              color: Colors.white), // Use close icon for "cancel"
          onPressed: () =>
              Navigator.of(context).pop(false), // Pass false on cancel
        ),
        title: const Text(
          "Edit Character",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: save,
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Helper method for consistent input field styling
            _buildInputField(nameController, 'Name'),
            const SizedBox(height: 16),

            // Option 1: TextField for Status (as per original code)
            // _buildInputField(statusController, 'Status'),
            // Option 2: Dropdown for Status (recommended for fixed options)
            _buildDropdownField(
              'Status',
              _selectedStatus,
              ['Alive', 'Dead', 'Unknown'],
              (value) {
                setState(() => _selectedStatus = value);
              },
            ),
            const SizedBox(height: 16),

            // Option 1: TextField for Species (as per original code)
            // _buildInputField(speciesController, 'Species'),
            // Option 2: Dropdown for Species (recommended for fixed options)
            _buildDropdownField(
              'Species',
              _selectedSpecies,
              [
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
              ], // Expanded list
              (value) {
                setState(() => _selectedSpecies = value);
              },
            ),
            const SizedBox(height: 16),

            _buildInputField(typeController, 'Type'),
            const SizedBox(height: 16),

            // Option 1: TextField for Gender (as per original code)
            // _buildInputField(genderController, 'Gender'),
            // Option 2: Dropdown for Gender (recommended for fixed options)
            _buildDropdownField(
              'Gender',
              _selectedGender,
              ['Male', 'Female', 'Genderless', 'Unknown'],
              (value) {
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: 16),

            _buildInputField(originController, 'Origin Name'),
            const SizedBox(height: 16),

            _buildInputField(locationController, 'Location Name'),
            const SizedBox(height: 32),

            // Moved Save to AppBar actions, but keeping this as an alternative if needed
            // ElevatedButton(
            //   onPressed: save,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.purple, // A distinct color for the button
            //     minimumSize: const Size(double.infinity, 50), // Full width button
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   child: const Text(
            //     "Save Changes",
            //     style: TextStyle(fontSize: 18, color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Helper widget for consistent TextField styling
  Widget _buildInputField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white), // Input text color
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor:
            const Color(0xFF2C2C2E), // Darker grey for input field background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // No border line
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Colors.purple, width: 2), // Highlight on focus
        ),
      ),
    );
  }

  // Helper widget for consistent DropdownButton styling
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
      isEmpty: currentValue == null ||
          currentValue == 'Unknown' ||
          currentValue.isEmpty,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue == 'Unknown' || currentValue!.isEmpty
              ? null
              : currentValue,
          isExpanded: true,
          dropdownColor:
              const Color(0xFF2C2C2E), // Dropdown menu background color
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
}
