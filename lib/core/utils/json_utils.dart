import 'dart:math';

class JsonUtils {
  static String asString(dynamic v) => v?.toString() ?? '';

  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static int? tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static int calculateCpAtLevel(int attack, int defense, int stamina, double level) {
    if (attack == 0 && defense == 0 && stamina == 0) return 0;
    
    // Standard CPM values for specific levels
    final Map<double, double> cpmMap = {
      20.0: 0.59740001,
      25.0: 0.667934,
      40.0: 0.79030001,
      50.0: 0.84029999,
    };
    
    final cpMultiplier = cpmMap[level] ?? 0.84029999; // Default to Level 50
    
    // CP = floor((Base_Attack + IV_Attack) * sqrt(Base_Defense + IV_Defense) * sqrt(Base_Stamina + IV_Stamina) * CPM^2 / 10)
    // Here we assume perfect IVs (15/15/15)
    final totalAttack = attack + 15;
    final totalDefense = defense + 15;
    final totalStamina = stamina + 15;
    
    final cp = (totalAttack * sqrt(totalDefense) * sqrt(totalStamina) * pow(cpMultiplier, 2)) / 10.0;
    return max(10, cp.floor());
  }

  static int calculateMaxCp(int attack, int defense, int stamina) {
    return calculateCpAtLevel(attack, defense, stamina, 50.0);
  }
}
