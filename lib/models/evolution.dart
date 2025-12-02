import '../core/utils/json_utils.dart';

class Evolution {
  final String evolutionId; // The Pokemon ID of the evolution (e.g. "IVYSAUR")
  final int candyCost;
  final String? formId; // The specific form ID (e.g. "IVYSAUR_NORMAL")
  final String? itemRequirement;
  final int? genderRequirement; // 1=male, 2=female

  const Evolution({
    required this.evolutionId,
    required this.candyCost,
    this.formId,
    this.itemRequirement,
    this.genderRequirement,
  });



  factory Evolution.fromJson(Map<String, dynamic> json) {
    return Evolution(
      evolutionId: json['evolution']?.toString() ?? '',
      candyCost: JsonUtils.parseInt(json['candyCost']),
      formId: json['form']?.toString(),
      itemRequirement: json['itemRequirement']?.toString(),
      genderRequirement: JsonUtils.tryParseInt(json['genderRequirement']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evolution': evolutionId,
      'candyCost': candyCost,
      'form': formId,
      'itemRequirement': itemRequirement,
      'genderRequirement': genderRequirement,
    };
  }
}
