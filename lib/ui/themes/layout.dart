import 'package:seagull/utils/all.dart';

import 'all.dart';

class Lay {
  static final Lay out = Device.screenSize.longestSide > 1500
      ? const LargeLayout()
      : Device.screenSize.longestSide > 1000
          ? const MediumLayout()
          : const GoLayout();

  final AppBarLayout appBar;
  final ActionButtonLayout actionButton;
  final ClockLayout clock;
  final FontSize fontSize;
  final IconSize iconSize;

  const Lay({
    this.appBar = const AppBarLayout(),
    this.actionButton = const ActionButtonLayout(),
    this.clock = const ClockLayout(),
    this.fontSize = const FontSize(),
    this.iconSize = const IconSize(),
  });
}

class AppBarLayout {
  final double horizontalPadding, height;

  const AppBarLayout({
    this.horizontalPadding = 16,
    this.height = 80,
  });
}

class ActionButtonLayout {
  final double size, radius;

  const ActionButtonLayout({
    this.size = 48,
    this.radius = 12,
  });
}

class ClockLayout {
  final double height,
      width,
      borderWidth,
      centerPointRadius,
      hourNumberScale,
      hourHandLength,
      minuteHandLength,
      fontSize;

  const ClockLayout({
    this.height = 60,
    this.width = 48,
    this.borderWidth = 1,
    this.centerPointRadius = 4,
    this.hourNumberScale = 1.5,
    this.hourHandLength = 11,
    this.minuteHandLength = 15,
    this.fontSize = 7,
  });
}

class FontSize {
  final double headline1,
      headline2,
      headline3,
      headline4,
      headline5,
      headline6,
      subtitle1,
      subtitle2,
      bodyText1,
      bodyText2,
      caption,
      button,
      overline;

  const FontSize({
    this.headline1 = 96,
    this.headline2 = 60,
    this.headline3 = 48,
    this.headline4 = 34,
    this.headline5 = 24,
    this.headline6 = 20,
    this.subtitle1 = 16,
    this.subtitle2 = 14,
    this.bodyText1 = 16,
    this.bodyText2 = 14,
    this.caption = 12,
    this.button = 16,
    this.overline = 10,
  });
}

class IconSize {
  final double small, button, normal, large, huge;

  const IconSize({
    this.small = 24,
    this.button = 28,
    this.normal = 32,
    this.large = 48,
    this.huge = 96,
  });
}
