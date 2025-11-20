import 'package:flutter/material.dart';

/// Reusable widget to display Pokemon stats in a formatted row
class StatsRow extends StatelessWidget {
  final int attack;
  final int defense;
  final int stamina;
  final String? formLabel;
  final TextStyle? textStyle;

  const StatsRow({
    super.key,
    required this.attack,
    required this.defense,
    required this.stamina,
    this.formLabel,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? Theme.of(context).textTheme.bodySmall;
    final statsText = 'ATK $attack | DEF $defense | STA $stamina';
    final fullText =
        formLabel != null ? '$statsText  •  $formLabel' : statsText;

    return Text(
      fullText,
      style: style,
    );
  }
}
