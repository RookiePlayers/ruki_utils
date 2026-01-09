import 'package:flutter/material.dart';
import 'package:ruki_utils/src/color_utils.dart';


extension ColorExtention on Color {
  Color withShade(double factor) => ColorMisc.withShade(this, factor);

  Color withTint(double factor) => ColorMisc.withTint(this, factor);

  Color get contrastText => ColorMisc.contrastText(this);

  static Color fromHex(String hexString) => ColorMisc.fromHex(hexString);

  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${a.round().toRadixString(16).padLeft(2, '0')}'
      '${r.round().toRadixString(16).padLeft(2, '0')}'
      '${g.round().toRadixString(16).padLeft(2, '0')}'
      '${b.round().toRadixString(16).padLeft(2, '0')}';

  Color withOpacity(double opacity) => withAlpha((255.0 * opacity).round());
}
