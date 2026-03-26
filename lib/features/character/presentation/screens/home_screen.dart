import 'package:flutter/material.dart';
import 'character_list_screen.dart';
import 'favorites_screen.dart';

// Placeholder for the third screen in the bottom navigation
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Consistent dark background
      appBar: AppBar(
        title:
            const Text("More Options", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          "This is a placeholder for additional content.",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  // Added PlaceholderScreen for the third tab
  final pages = const [
    CharacterListScreen(),
    FavoritesScreen(),
    PlaceholderScreen(), // Placeholder for the third tab from screenshot
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          setState(() => index = i);
        },
        backgroundColor: Colors.black, // Dark background as per screenshot
        selectedItemColor: Colors
            .purple, // Example color, adjust to match screenshot's active icon color
        unselectedItemColor: Colors.grey, // Example color for inactive icons
        type: BottomNavigationBarType
            .fixed, // Ensure all labels are shown, useful for more than 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Home icon as per screenshot
            label: "Home", // Label to match the icon's implied meaning
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), // Hash symbol as per screenshot
            label:
                "Favorites", // Assuming this tab is for characters, but screenshot uses different text
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward), // Right arrow as per screenshot
            label: "More", // Generic label for the third tab
          ),
        ],
      ),
    );
  }
}
