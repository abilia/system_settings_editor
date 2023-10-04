import 'package:flutter/widgets.dart';
import 'package:handi/ui/layout/tokens/numericals.dart';
import 'package:handi/ui/layout/tokens/paddings.dart';

class ActionButtonLayout {
  final double size, iconSize, radius, spacing;
  final EdgeInsets padding;

  const ActionButtonLayout({
    this.size = numerical1000,
    this.iconSize = numerical800,
    this.radius = numerical200,
    this.padding = buttonHorizontalPadding,
    this.spacing = numerical200,
  });
}
