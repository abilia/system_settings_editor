import 'package:flutter/material.dart';

extension TextStyleWithColor on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
}
