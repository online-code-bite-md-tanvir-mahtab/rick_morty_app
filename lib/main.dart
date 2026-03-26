import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rick_morty_app/features/character/presentation/screens/home_screen.dart';

import 'features/character/presentation/screens/character_list_screen.dart';
import 'features/character/data/models/character_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CharacterModelAdapter());

  await Hive.openBox('charactersBox');
  await Hive.openBox('favoritesBox');
  await Hive.openBox('editsBox');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
