import 'pokemon_form.dart';
import '../core/utils/json_utils.dart';

/// Represents a Pokémon species with all its forms
class PokemonEntry {
  final String basePokemonId;
  final String name;
  final String defaultPokemonId;
  final List<String> types;
  final int baseAttack;
  final int baseDefense;
  final int baseStamina;
  final bool hasCostumeForms;
  final int? dexNumber;
  final String? goIconUrl;
  final List<PokemonForm> forms;
  final int maxCp;

  const PokemonEntry({
    required this.basePokemonId,
    required this.name,
    required this.defaultPokemonId,
    required this.types,
    required this.baseAttack,
    required this.baseDefense,
    required this.baseStamina,
    required this.hasCostumeForms,
    required this.dexNumber,
    required this.goIconUrl,
    required this.forms,
    required this.maxCp,
  });

  factory PokemonEntry.fromJson(Map<String, dynamic> json) {
    String asString(dynamic v) => v?.toString() ?? '';
    final typesRaw = json['types'] as List<dynamic>? ?? const [];
    final int baseAttack = JsonUtils.parseInt(json['baseAttack']);
    final int baseDefense = JsonUtils.parseInt(json['baseDefense']);
    final int baseStamina = JsonUtils.parseInt(json['baseStamina']);
    final int? maxCp = JsonUtils.tryParseInt(json['maxCp']);
    final formsRaw = json['forms'] as List<dynamic>? ?? const [];

    return PokemonEntry(
      basePokemonId: asString(json['basePokemonId']),
      name: asString(json['name']),
      defaultPokemonId: asString(json['defaultPokemonId']),
      types: typesRaw.map((e) => e.toString()).toList(),
      baseAttack: baseAttack,
      baseDefense: baseDefense,
      baseStamina: baseStamina,
      hasCostumeForms: json['hasCostumeForms'] as bool? ?? false,
      dexNumber: JsonUtils.tryParseInt(json['dexNumber']),
      goIconUrl: json['goIconUrl']?.toString(),
      forms: formsRaw
          .map((e) => PokemonForm.fromJson(e as Map<String, dynamic>))
          .toList(),
      maxCp: maxCp ?? JsonUtils.calculateMaxCp(baseAttack, baseDefense, baseStamina),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePokemonId': basePokemonId,
      'name': name,
      'defaultPokemonId': defaultPokemonId,
      'types': types,
      'baseAttack': baseAttack,
      'baseDefense': baseDefense,
      'baseStamina': baseStamina,
      'hasCostumeForms': hasCostumeForms,
      'dexNumber': dexNumber,
      'goIconUrl': goIconUrl,
      'forms': forms.map((e) => e.toJson()).toList(),
      'maxCp': maxCp,
    };
  }

  PokemonForm? get defaultForm {
    return forms.isNotEmpty ? forms.first : null;
  }

  int get formCount => forms.length;

  PokemonEntry copyWith({
    String? basePokemonId,
    String? name,
    String? defaultPokemonId,
    List<String>? types,
    int? baseAttack,
    int? baseDefense,
    int? baseStamina,
    bool? hasCostumeForms,
    int? dexNumber,
    String? goIconUrl,
    List<PokemonForm>? forms,
    int? maxCp,
  }) {
    return PokemonEntry(
      basePokemonId: basePokemonId ?? this.basePokemonId,
      name: name ?? this.name,
      defaultPokemonId: defaultPokemonId ?? this.defaultPokemonId,
      types: types ?? this.types,
      baseAttack: baseAttack ?? this.baseAttack,
      baseDefense: baseDefense ?? this.baseDefense,
      baseStamina: baseStamina ?? this.baseStamina,
      hasCostumeForms: hasCostumeForms ?? this.hasCostumeForms,
      dexNumber: dexNumber ?? this.dexNumber,
      goIconUrl: goIconUrl ?? this.goIconUrl,
      forms: forms ?? this.forms,
      maxCp: maxCp ?? this.maxCp,
    );
  }
}
