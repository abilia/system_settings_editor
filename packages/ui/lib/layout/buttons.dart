import 'package:flutter/widgets.dart';
import 'package:ui/tokens/numericals.dart';
import 'package:ui/tokens/paddings.dart';

class ActionButtonLayout {
  final double iconSize, spacing;
  final EdgeInsets padding;

  const ActionButtonLayout({
    this.iconSize = numerical800,
    this.padding = buttonHorizontalPadding,
    this.spacing = numerical200,
  });
}
