import 'package:seagull/ui/all.dart';

class CategoryLayout {
  final double height,
      radius,
      startPadding,
      endPadding,
      emptySize,
      topMargin,
      imageDiameter,
      noColorsImageSize;
  final EdgeInsets activityRadioPadding, settingsRadioPadding, imagePadding;

  const CategoryLayout({
    this.height = 44,
    this.radius = 22,
    this.startPadding = 8,
    this.endPadding = 4,
    this.emptySize = 16,
    this.topMargin = 4,
    this.imageDiameter = 36,
    this.noColorsImageSize = 30,
    this.activityRadioPadding = const EdgeInsets.all(8),
    this.settingsRadioPadding = const EdgeInsets.all(4),
    this.imagePadding = const EdgeInsets.all(3),
  });
}

class CategoryLayoutMedium extends CategoryLayout {
  const CategoryLayoutMedium({
    double? height,
    double? radius,
    double? endPadding,
    double? emptySize,
    double? topMargin,
    double? imageDiameter,
    double? noColorsImageSize,
    EdgeInsets? radioPadding,
    EdgeInsets? imagePadding,
  }) : super(
          height: height ?? 66,
          radius: radius ?? 33,
          startPadding: 12,
          endPadding: endPadding ?? 6,
          emptySize: emptySize ?? 24,
          topMargin: topMargin ?? 8,
          imageDiameter: imageDiameter ?? 54,
          noColorsImageSize: noColorsImageSize ?? 45,
          activityRadioPadding: radioPadding ?? const EdgeInsets.all(12),
          settingsRadioPadding: const EdgeInsets.all(6),
          imagePadding: imagePadding ?? const EdgeInsets.all(4.5),
        );
}

class CategoryLayoutLarge extends CategoryLayoutMedium {
  const CategoryLayoutLarge()
      : super(
          height: 88,
          radius: 42,
          endPadding: 8,
          emptySize: 32,
          topMargin: 12,
          imageDiameter: 72,
          noColorsImageSize: 60,
          radioPadding: const EdgeInsets.all(8),
          imagePadding: const EdgeInsets.all(6),
        );
}
