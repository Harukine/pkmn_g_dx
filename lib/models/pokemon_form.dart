/// Enum representing the type of form
enum FormType {
  normal,
  regional,
  mega,
  primal,
  shadow,
  purified,
  costume,
  special;

  String get displayName {
    switch (this) {
      case FormType.normal:
        return 'Normal';
      case FormType.regional:
        return 'Regional';
      case FormType.mega:
        return 'Mega Evolution';
      case FormType.primal:
        return 'Primal Reversion';
      case FormType.shadow:
        return 'Shadow';
      case FormType.purified:
        return 'Purified';
      case FormType.costume:
        return 'Costume';
      case FormType.special:
        return 'Special';
    }
  }

  static FormType fromString(String? value) {
    if (value == null) return FormType.normal;
    try {
      return FormType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => FormType.normal,
      );
    } catch (_) {
      return FormType.normal;
    }
  }
}

/// Represents a specific form/variant of a Pokémon
class PokemonForm {
  final String pokemonId;
  final String? formId; // e.g. "NORMAL", "ALOLA", "FALL_2019"
  final String formName; // "Normal", "Alola", "Fall 2019"
  final FormType formType;
  final List<String> types;
  final int baseAttack;
  final int baseDefense;
  final int baseStamina;
  final int? dexNumber;
  final String? spriteUrl; // PokeAPI fallback
  final String? goIconUrl; // Pokémon GO icon (preferred)

  // Backward compatibility
  bool get isCostume => formType == FormType.costume;
  bool get isBattleForm =>
      formType == FormType.mega ||
      formType == FormType.primal ||
      formType == FormType.regional ||
      formType == FormType.normal ||
      formType == FormType.shadow ||
      formType == FormType.purified;

  const PokemonForm({
    required this.pokemonId,
    required this.formId,
    required this.formName,
    required this.formType,
    required this.types,
    required this.baseAttack,
    required this.baseDefense,
    required this.baseStamina,
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
      formType: FormType.fromString(json['formType']?.toString()),
      types: typesRaw.map((e) => e.toString()).toList(),
      baseAttack: (json['baseAttack'] as num? ?? 0).toInt(),
      baseDefense: (json['baseDefense'] as num? ?? 0).toInt(),
      baseStamina: (json['baseStamina'] as num? ?? 0).toInt(),
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
      'formType': formType.name,
      'types': types,
      'baseAttack': baseAttack,
      'baseDefense': baseDefense,
      'baseStamina': baseStamina,
      'dexNumber': dexNumber,
      'spriteUrl': spriteUrl,
      'goIconUrl': goIconUrl,
    };
  }

  PokemonForm copyWith({
    String? pokemonId,
    String? formId,
    String? formName,
    FormType? formType,
    List<String>? types,
    int? baseAttack,
    int? baseDefense,
    int? baseStamina,
    int? dexNumber,
    String? spriteUrl,
    String? goIconUrl,
  }) {
    return PokemonForm(
      pokemonId: pokemonId ?? this.pokemonId,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      formType: formType ?? this.formType,
      types: types ?? this.types,
      baseAttack: baseAttack ?? this.baseAttack,
      baseDefense: baseDefense ?? this.baseDefense,
      baseStamina: baseStamina ?? this.baseStamina,
      dexNumber: dexNumber ?? this.dexNumber,
      spriteUrl: spriteUrl ?? this.spriteUrl,
      goIconUrl: goIconUrl ?? this.goIconUrl,
    );
  }
}
