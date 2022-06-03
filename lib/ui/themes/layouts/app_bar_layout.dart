import 'package:seagull/ui/all.dart';

class AppBarLayout {
  final double horizontalPadding,
      largeAppBarHeight,
      height,
      fontSize,
      previewWidth;

  final BorderRadius borderRadius;

  const AppBarLayout({
    this.horizontalPadding = 16,
    this.largeAppBarHeight = 80,
    this.height = 68,
    this.fontSize = 22,
    this.previewWidth = 375,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    ),
  });
}

class MediumAppBarLayout extends AppBarLayout {
  const MediumAppBarLayout({
    double? largeAppBarHeight,
  }) : super(
          horizontalPadding: 16,
          largeAppBarHeight: largeAppBarHeight ?? 148,
          height: 104,
          fontSize: 32,
          previewWidth: 562.5,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        );
}

class LargeAppBarLayout extends MediumAppBarLayout {
  const LargeAppBarLayout()
      : super(
          largeAppBarHeight: 200,
        );
}
