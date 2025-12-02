import 'evolution.dart';
import '../core/utils/json_utils.dart';

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
  final String? goIconUrl; // Pokémon GO icon (preferred)
  final String? shinyGoIconUrl;
  final bool isCostume;
  
  // New fields
  final String? familyId;
  final List<String> quickMoves;
  final List<String> cinematicMoves;
  final List<String> eliteQuickMoves;
  final List<String> eliteCinematicMoves;
  final List<Evolution> nextEvolutions;
  final int? thirdMoveStardust;
  final int? thirdMoveCandy;

  // Backward compatibility
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
    required this.goIconUrl,
    this.shinyGoIconUrl,
    this.isCostume = false,
    this.familyId,
    this.quickMoves = const [],
    this.cinematicMoves = const [],
    this.eliteQuickMoves = const [],
    this.eliteCinematicMoves = const [],
    this.nextEvolutions = const [],
    this.thirdMoveStardust,
    this.thirdMoveCandy,
  });



  factory PokemonForm.fromJson(Map<String, dynamic> json) {
    String asString(dynamic v) => v?.toString() ?? '';
    final typesRaw = json['types'] as List<dynamic>? ?? const [];
    
    final quickMovesRaw = json['quickMoves'] as List<dynamic>? ?? const [];
    final cinematicMovesRaw = json['cinematicMoves'] as List<dynamic>? ?? const [];
    final eliteQuickMovesRaw = json['eliteQuickMoves'] as List<dynamic>? ?? const [];
    final eliteCinematicMovesRaw = json['eliteCinematicMoves'] as List<dynamic>? ?? const [];
    
    final evolutionData = json['evolution'] as Map<String, dynamic>? ?? {};
    final nextEvolutionsRaw = evolutionData['nextEvolutions'] as List<dynamic>? ?? const [];

    return PokemonForm(
      pokemonId: asString(json['pokemonId']),
      formId: json['formId']?.toString(),
      formName: asString(json['formName']),
      formType: FormType.fromString(json['formType']?.toString()),
      types: typesRaw.map((e) => e.toString()).toList(),
      baseAttack: JsonUtils.parseInt(json['baseAttack']),
      baseDefense: JsonUtils.parseInt(json['baseDefense']),
      baseStamina: JsonUtils.parseInt(json['baseStamina']),
      dexNumber: JsonUtils.parseInt(json['dexNumber']),
      goIconUrl: json['goIconUrl']?.toString(),
      shinyGoIconUrl: json['shinyGoIconUrl']?.toString(),
      isCostume: json['isCostume'] as bool? ?? false,
      familyId: json['familyId']?.toString(),
      quickMoves: quickMovesRaw.map((e) => e.toString()).toList(),
      cinematicMoves: cinematicMovesRaw.map((e) => e.toString()).toList(),
      eliteQuickMoves: eliteQuickMovesRaw.map((e) => e.toString()).toList(),
      eliteCinematicMoves: eliteCinematicMovesRaw.map((e) => e.toString()).toList(),
      nextEvolutions: nextEvolutionsRaw
          .map((e) => Evolution.fromJson(e as Map<String, dynamic>))
          .toList(),
      thirdMoveStardust: JsonUtils.tryParseInt(evolutionData['thirdMoveStardust']),
      thirdMoveCandy: JsonUtils.tryParseInt(evolutionData['thirdMoveCandy']),
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
      'goIconUrl': goIconUrl,
      'shinyGoIconUrl': shinyGoIconUrl,
      'isCostume': isCostume,
      'familyId': familyId,
      'quickMoves': quickMoves,
      'cinematicMoves': cinematicMoves,
      'eliteQuickMoves': eliteQuickMoves,
      'eliteCinematicMoves': eliteCinematicMoves,
      'evolution': {
        'nextEvolutions': nextEvolutions.map((e) => e.toJson()).toList(),
        'thirdMoveStardust': thirdMoveStardust,
        'thirdMoveCandy': thirdMoveCandy,
      },
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
    String? goIconUrl,
    String? shinyGoIconUrl, // Added as per instruction
    bool? isCostume, // Added as per instruction
    String? familyId,
    List<String>? quickMoves,
    List<String>? cinematicMoves,
    List<String>? eliteQuickMoves,
    List<String>? eliteCinematicMoves,
    List<Evolution>? nextEvolutions,
    int? thirdMoveStardust,
    int? thirdMoveCandy,
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
      goIconUrl: goIconUrl ?? this.goIconUrl,
      shinyGoIconUrl: shinyGoIconUrl ?? this.shinyGoIconUrl,
      isCostume: isCostume ?? this.isCostume,
      familyId: familyId ?? this.familyId,
      quickMoves: quickMoves ?? this.quickMoves,
      cinematicMoves: cinematicMoves ?? this.cinematicMoves,
      eliteQuickMoves: eliteQuickMoves ?? this.eliteQuickMoves,
      eliteCinematicMoves: eliteCinematicMoves ?? this.eliteCinematicMoves,
      nextEvolutions: nextEvolutions ?? this.nextEvolutions,
      thirdMoveStardust: thirdMoveStardust ?? this.thirdMoveStardust,
      thirdMoveCandy: thirdMoveCandy ?? this.thirdMoveCandy,
    );
  }
}
