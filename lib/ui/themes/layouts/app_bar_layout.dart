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

class MediumClockLayout extends ClockLayout {
  const MediumClockLayout({
    double? height,
    double? width,
  }) : super(
          height: height ?? 124,
          width: width ?? 92,
          borderWidth: 2,
          centerPointRadius: 8,
          hourNumberScale: 1.5,
          hourHandLength: 22,
          minuteHandLength: 30,
          hourHandWidth: 1.5,
          minuteHandWidth: 1.5,
          fontSize: 12,
        );
}

class MediumFontSize extends FontSize {
  const MediumFontSize({
    double? headline6,
  }) : super(
          headline1: 144,
          headline2: 90,
          headline3: 72,
          headline4: 45,
          headline5: 38,
          headline6: headline6 ?? 32,
          subtitle1: 24,
          subtitle2: 21,
          bodyText1: 24,
          bodyText2: 21,
          caption: 20,
          button: 24,
          overline: 15,
        );
}

class LargeAppBarLayout extends MediumAppBarLayout {
  const LargeAppBarLayout()
      : super(
          largeAppBarHeight: 200,
        );
}

class LargeActionButtonLayout extends MediumActionButtonLayout {
  const LargeActionButtonLayout()
      : super(
          size: 120,
        );
}

class LargeClockLayout extends MediumClockLayout {
  const LargeClockLayout()
      : super(
          height: 172,
          width: 172,
        );
}

class LargeFontSize extends MediumFontSize {
  const LargeFontSize()
      : super(
          headline6: 48,
        );
}
