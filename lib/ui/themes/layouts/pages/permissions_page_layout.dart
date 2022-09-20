import 'package:flutter/material.dart';

class PermissionsPageLayout {
  final double deniedDotPosition, deniedContainerSize, deniedBorderRadius;

  final EdgeInsets deniedPadding, deniedVerticalPadding;

  const PermissionsPageLayout({
    this.deniedDotPosition = -10,
    this.deniedContainerSize = 32,
    this.deniedBorderRadius = 16,
    this.deniedPadding = const EdgeInsets.only(top: 4),
    this.deniedVerticalPadding = const EdgeInsets.symmetric(vertical: 4),
  });
}
