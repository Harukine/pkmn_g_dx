import 'package:flutter/material.dart';

import 'core/themes/app_theme.dart';
import 'screens/list/pokemon_list_page.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex GO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PokemonListPage(),
    );
  }
}