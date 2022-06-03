import 'package:seagull/ui/all.dart';

class ActionButtonLayout {
  final double size, radius, spacing;
  final EdgeInsets padding, withTextPadding;

  const ActionButtonLayout({
    this.size = 48,
    this.radius = 12,
    this.spacing = 0,
    this.padding = const EdgeInsets.all(8),
    this.withTextPadding = const EdgeInsets.only(left: 4, top: 4, right: 4),
  });
}

class MediumActionButtonLayout extends ActionButtonLayout {
  const MediumActionButtonLayout({
    double? size,
  }) : super(
          size: size ?? 88,
          radius: 20,
          spacing: 4,
          padding: const EdgeInsets.all(12),
          withTextPadding: const EdgeInsets.only(left: 6, top: 6, right: 6),
        );
}

class LargeActionButtonLayout extends MediumActionButtonLayout {
  const LargeActionButtonLayout()
      : super(
          size: 120,
        );
}
