/// Represents a specific form/variant of a Pokémon
class PokemonForm {
  final String pokemonId;
  final String? formId; // e.g. "NORMAL", "ALOLA", "FALL_2019"
  final String formName; // "Normal", "Alola", "Fall 2019"
  final List<String> types;
  final int baseAttack;
  final int baseDefense;
  final int baseStamina;
  final bool isCostume;
  final int? dexNumber;
  final String? spriteUrl; // PokeAPI fallback
  final String? goIconUrl; // Pokémon GO icon (preferred)

  const PokemonForm({
    required this.pokemonId,
    required this.formId,
    required this.formName,
    required this.types,
    required this.baseAttack,
    required this.baseDefense,
    required this.baseStamina,
    required this.isCostume,
    required this.dexNumber,
    required this.spriteUrl,
    required this.goIconUrl,
  });

  factory PokemonForm.fromJson(Map<String, dynamic> json) {
    String asString(dynamic v) => v?.toString() ?? '';
    final typesRaw = json['types'] as List<dynamic>? ?? const [];

    return PokemonForm(
      pokemonId: asString(json['pokemonId']),
      formId: json['formId']?.toString(),
      formName: asString(json['formName']),
      types: typesRaw.map((e) => e.toString()).toList(),
      baseAttack: (json['baseAttack'] as num? ?? 0).toInt(),
      baseDefense: (json['baseDefense'] as num? ?? 0).toInt(),
      baseStamina: (json['baseStamina'] as num? ?? 0).toInt(),
      isCostume: json['isCostume'] as bool? ?? false,
      dexNumber: (json['dexNumber'] as num?)?.toInt(),
      spriteUrl: json['spriteUrl']?.toString(),
      goIconUrl: json['goIconUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pokemonId': pokemonId,
      'formId': formId,
      'formName': formName,
      'types': types,
      'baseAttack': baseAttack,
      'baseDefense': baseDefense,
      'baseStamina': baseStamina,
      'isCostume': isCostume,
      'dexNumber': dexNumber,
      'spriteUrl': spriteUrl,
      'goIconUrl': goIconUrl,
    };
  }

  PokemonForm copyWith({
    String? pokemonId,
    String? formId,
    String? formName,
    List<String>? types,
    int? baseAttack,
    int? baseDefense,
    int? baseStamina,
    bool? isCostume,
    int? dexNumber,
    String? spriteUrl,
    String? goIconUrl,
  }) {
    return PokemonForm(
      pokemonId: pokemonId ?? this.pokemonId,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      types: types ?? this.types,
      baseAttack: baseAttack ?? this.baseAttack,
      baseDefense: baseDefense ?? this.baseDefense,
      baseStamina: baseStamina ?? this.baseStamina,
      isCostume: isCostume ?? this.isCostume,
      dexNumber: dexNumber ?? this.dexNumber,
      spriteUrl: spriteUrl ?? this.spriteUrl,
      goIconUrl: goIconUrl ?? this.goIconUrl,
    );
  }
}
