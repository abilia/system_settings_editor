import 'package:memoplanner/ui/all.dart';

class ActionButtonLayout {
  final double size,
      largeSize,
      smallSize,
      iconSize,
      radius,
      largeRadius,
      spacing,
      withTextIconSize,
      withTextIconSizeSmall;
  final EdgeInsets padding, withTextPadding;

  const ActionButtonLayout({
    this.size = 48,
    this.largeSize = 48,
    this.smallSize = 48,
    this.iconSize = 32,
    this.radius = 12,
    this.largeRadius = 12,
    this.spacing = 0,
    this.padding = const EdgeInsets.all(8),
    this.withTextPadding = const EdgeInsets.only(left: 4, top: 4, right: 4),
    this.withTextIconSize = 24,
    this.withTextIconSizeSmall = 24,
  });
}

class ActionButtonLayoutMedium extends ActionButtonLayout {
  const ActionButtonLayoutMedium({
    double? largeSize,
    double? largeRadius,
    double? withTextIconSizeSmall,
  }) : super(
          size: 88,
          largeSize: largeSize ?? 88,
          smallSize: 80,
          iconSize: 56,
          radius: 20,
          largeRadius: largeRadius ?? 20,
          spacing: 4,
          padding: const EdgeInsets.all(12),
          withTextPadding: const EdgeInsets.only(top: 6, left: 4, right: 4),
          withTextIconSize: 48,
          withTextIconSizeSmall: withTextIconSizeSmall ?? 32,
        );
}

class ActionButtonLayoutLarge extends ActionButtonLayoutMedium {
  const ActionButtonLayoutLarge()
      : super(
          largeSize: 120,
          largeRadius: 32,
          withTextIconSizeSmall: 48,
        );
}
