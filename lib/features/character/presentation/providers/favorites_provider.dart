import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((
  ref,
) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  final Box box = Hive.box('favoritesBox');

  FavoritesNotifier() : super({}) {
    loadFavorites();
  }

  void loadFavorites() {
    final keys = box.keys.cast<int>().toSet();
    state = keys;
  }

  void toggle(int id) {
    if (state.contains(id)) {
      box.delete(id);
      state = {...state}..remove(id);
    } else {
      box.put(id, true);
      state = {...state, id};
    }
  }

  bool isFavorite(int id) {
    return state.contains(id);
  }
}
