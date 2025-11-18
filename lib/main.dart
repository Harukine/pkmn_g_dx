import 'package:flutter/material.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO Pokédex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PokemonListPage(),
    );
  }
}

class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
  });
}

// For now, just some hard-coded starters
const kPokemonList = <Pokemon>[
  Pokemon(
    id: 1,
    name: 'Bulbasaur',
    types: ['Grass', 'Poison'],
    imageUrl:
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
  ),
  Pokemon(
    id: 4,
    name: 'Charmander',
    types: ['Fire'],
    imageUrl:
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png',
  ),
  Pokemon(
    id: 7,
    name: 'Squirtle',
    types: ['Water'],
    imageUrl:
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png',
  ),
];

class PokemonListPage extends StatelessWidget {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GO Pokédex'),
      ),
      body: ListView.builder(
        itemCount: kPokemonList.length,
        itemBuilder: (context, index) {
          final pokemon = kPokemonList[index];
          return PokemonCard(pokemon: pokemon);
        },
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Image.network(
          pokemon.imageUrl,
          width: 56,
          height: 56,
        ),
        title: Text('#${pokemon.id.toString().padLeft(3, "0")} ${pokemon.name}'),
        subtitle: Wrap(
          spacing: 6,
          children: pokemon.types
              .map(
                (t) => Chip(
              label: Text(t),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
              .toList(),
        ),
        onTap: () {
          // later: navigate to detail page
        },
      ),
    );
  }
}