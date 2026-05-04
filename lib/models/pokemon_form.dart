import 'evolution.dart';
import '../core/utils/json_utils.dart';
import '../core/constants/move_type_data.dart';

/// Enum representing the type of form
enum FormType {
  normal,
  regional,
  mega,
  primal,
  shadow,
  purified,
  gigantamax,
  costume,
  special;

  String get displayName {
    switch (this) {
      case FormType.normal:
        return 'Normal';
      case FormType.regional:
        return 'Regional';
      case FormType.mega:
        return 'Mega';
      case FormType.primal:
        return 'Primal';
      case FormType.shadow:
        return 'Shadow';
      case FormType.purified:
        return 'Purified';
      case FormType.gigantamax:
        return 'Gigantamax';
      case FormType.costume:
        return 'Costume';
      case FormType.special:
        return 'Special';
    }
  }

  static FormType fromString(String? value) {
    if (value == null) return FormType.normal;
    return FormType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FormType.normal,
    );
  }
}

/// Represents a requirement or mechanism for a Pokémon to change forms (e.g. Fusion, Items)
class FormChange {
  final List<String> availableForms;
  final int? candyCost;
  final int? stardustCost;
  final String? item;
  final int? itemCostCount;
  final List<String> replacementMoves;

  const FormChange({
    required this.availableForms,
    this.candyCost,
    this.stardustCost,
    this.item,
    this.itemCostCount,
    this.replacementMoves = const [],
  });

  factory FormChange.fromJson(Map<String, dynamic> json) {
    return FormChange(
      availableForms: (json['availableForm'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      candyCost: JsonUtils.tryParseInt(json['candyCost']),
      stardustCost: JsonUtils.tryParseInt(json['stardustCost']),
      item: json['item']?.toString(),
      itemCostCount: JsonUtils.tryParseInt(json['itemCostCount']),
      replacementMoves: (json['replacementMoves'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableForm': availableForms,
      'candyCost': candyCost,
      'stardustCost': stardustCost,
      'item': item,
      'itemCostCount': itemCostCount,
      'replacementMoves': replacementMoves,
    };
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
  final int maxCp;
  final String? bestQuickMove;
  final String? bestCinematicMove;
  final String? bestQuickMoveName; // Pre-calculated formatted name
  final String? bestCinematicMoveName; // Pre-calculated formatted name

  // Rich fields
  final bool isTransferable;
  final bool isTradable;
  final int? buddyDistance;
  final String? dynamaxTier;
  final String? parentPokemonId;
  final List<dynamic>? megaForms;
  final Map<String, dynamic>? shadowData;
  final List<FormChange> formChanges;
  final List<String> reassignedMoves;
  final String? pokemonClass;

  // Backward compatibility
  bool get isBattleForm =>
      formType == FormType.mega ||
      formType == FormType.primal ||
      formType == FormType.regional ||
      formType == FormType.normal ||
      formType == FormType.shadow ||
      formType == FormType.purified ||
      formType == FormType.gigantamax;

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
    required this.maxCp,
    this.bestQuickMove,
    this.bestCinematicMove,
    this.bestQuickMoveName,
    this.bestCinematicMoveName,
    this.isTransferable = true,
    this.isTradable = true,
    this.buddyDistance,
    this.dynamaxTier,
    this.parentPokemonId,
    this.megaForms,
    this.shadowData,
    this.formChanges = const [],
    this.reassignedMoves = const [],
    this.pokemonClass,
  });



  factory PokemonForm.fromJson(Map<String, dynamic> json) {
    final typesRaw = json['types'] as List<dynamic>? ?? const [];
    
    final quickMovesRaw = json['quickMoves'] as List<dynamic>? ?? const [];
    final cinematicMovesRaw = json['cinematicMoves'] as List<dynamic>? ?? const [];
    final eliteQuickMovesRaw = json['eliteQuickMoves'] as List<dynamic>? ?? const [];
    final eliteCinematicMovesRaw = json['eliteCinematicMoves'] as List<dynamic>? ?? const [];
    
    final evolutionData = json['evolution'] as Map<String, dynamic>? ?? {};
    final nextEvolutionsRaw = evolutionData['nextEvolutions'] as List<dynamic>? ?? const [];

    final bestQuickMove = json['bestQuickMove']?.toString();
    final bestCinematicMove = json['bestCinematicMove']?.toString();

    return PokemonForm(
      pokemonId: JsonUtils.asString(json['pokemonId']),
      formId: json['formId']?.toString(),
      formName: JsonUtils.asString(json['formName']),
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
      maxCp: json['maxCp'] != null 
          ? JsonUtils.parseInt(json['maxCp']) 
          : JsonUtils.calculateMaxCp(
              JsonUtils.parseInt(json['baseAttack']), 
              JsonUtils.parseInt(json['baseDefense']), 
              JsonUtils.parseInt(json['baseStamina'])
            ),
      bestQuickMove: bestQuickMove,
      bestCinematicMove: bestCinematicMove,
      bestQuickMoveName: bestQuickMove != null ? MoveTypeData.displayName(bestQuickMove) : null,
      bestCinematicMoveName: bestCinematicMove != null ? MoveTypeData.displayName(bestCinematicMove) : null,
      isTransferable: json['isTransferable'] as bool? ?? true,
      isTradable: json['isTradable'] as bool? ?? true,
      buddyDistance: JsonUtils.tryParseInt(json['buddyDistance']),
      dynamaxTier: json['dynamaxTier']?.toString(),
      parentPokemonId: json['parentPokemonId']?.toString(),
      megaForms: json['megaForms'] as List<dynamic>?,
      shadowData: json['shadowData'] as Map<String, dynamic>?,
      formChanges: (json['formChanges'] as List<dynamic>? ?? [])
          .map((e) => FormChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      reassignedMoves: (json['reassignedMoves'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      pokemonClass: json['pokemonClass'] as String?,
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
      'maxCp': maxCp,
      'bestQuickMove': bestQuickMove,
      'bestCinematicMove': bestCinematicMove,
      'isTransferable': isTransferable,
      'isTradable': isTradable,
      'buddyDistance': buddyDistance,
      'dynamaxTier': dynamaxTier,
      'parentPokemonId': parentPokemonId,
      'megaForms': megaForms,
      'shadowData': shadowData,
      'formChanges': formChanges.map((e) => e.toJson()).toList(),
      'reassignedMoves': reassignedMoves,
      'pokemonClass': pokemonClass,
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
    String? shinyGoIconUrl,
    bool? isCostume,
    String? familyId,
    List<String>? quickMoves,
    List<String>? cinematicMoves,
    List<String>? eliteQuickMoves,
    List<String>? eliteCinematicMoves,
    List<Evolution>? nextEvolutions,
    int? thirdMoveStardust,
    int? thirdMoveCandy,
    int? maxCp,
    String? bestQuickMove,
    String? bestCinematicMove,
    bool? isTransferable,
    bool? isTradable,
    int? buddyDistance,
    String? dynamaxTier,
    String? parentPokemonId,
    List<dynamic>? megaForms,
    Map<String, dynamic>? shadowData,
    List<FormChange>? formChanges,
    List<String>? reassignedMoves,
    String? pokemonClass,
    String? bestQuickMoveName,
    String? bestCinematicMoveName,
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
      bestQuickMove: bestQuickMove ?? this.bestQuickMove,
      bestCinematicMove: bestCinematicMove ?? this.bestCinematicMove,
      isTransferable: isTransferable ?? this.isTransferable,
      isTradable: isTradable ?? this.isTradable,
      buddyDistance: buddyDistance ?? this.buddyDistance,
      dynamaxTier: dynamaxTier ?? this.dynamaxTier,
      parentPokemonId: parentPokemonId ?? this.parentPokemonId,
      megaForms: megaForms ?? this.megaForms,
      shadowData: shadowData ?? this.shadowData,
      formChanges: formChanges ?? this.formChanges,
      reassignedMoves: reassignedMoves ?? this.reassignedMoves,
      pokemonClass: pokemonClass ?? this.pokemonClass,
      maxCp: maxCp ?? this.maxCp,
      bestQuickMoveName: bestQuickMoveName ?? this.bestQuickMoveName,
      bestCinematicMoveName: bestCinematicMoveName ?? this.bestCinematicMoveName,
    );
  }
}
