import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

part 'large_layout.dart';

part 'medium_layout.dart';

part 'go_layout.dart';

final Layout layout = Device.screenSize.longestSide > 1500
    ? const _LargeLayout()
    : Device.screenSize.longestSide > 1000
        ? const _MediumLayout()
        : const _GoLayout();

class Layout {
  final AppBarLayout appBar;
  final ActionButtonLayout actionButton;
  final TabBarLayout tabBar;
  final ToolbarLayout toolbar;
  final FontSize fontSize;
  final IconSize iconSize;
  final ClockLayout clock;
  final FormPaddingLayout formPadding;
  final MonthCalendarLayout monthCalendar;

  const Layout({
    this.appBar = const AppBarLayout(),
    this.actionButton = const ActionButtonLayout(),
    this.toolbar = const ToolbarLayout(),
    this.tabBar = const TabBarLayout(),
    this.fontSize = const FontSize(),
    this.iconSize = const IconSize(),
    this.clock = const ClockLayout(),
    this.formPadding = const FormPaddingLayout(),
    this.monthCalendar = const MonthCalendarLayout(),
  });

  bool get go => runtimeType == _GoLayout;
}

class AppBarLayout {
  final double horizontalPadding, height;

  const AppBarLayout({
    this.horizontalPadding = 16,
    this.height = 80,
  });
}

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

class ToolbarLayout {
  final double heigth, horizontalPadding, bottomPadding;

  const ToolbarLayout({
    this.heigth = 64,
    this.horizontalPadding = 16,
    this.bottomPadding = 0,
  });
}

class TabBarLayout {
  final TabItemLayout item;
  final double heigth, bottomPadding;

  const TabBarLayout({
    this.item = const TabItemLayout(),
    this.heigth = 64,
    this.bottomPadding = 0,
  });
}

class TabItemLayout {
  final double width, border;

  const TabItemLayout({
    this.width = 64,
    this.border = 1,
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

class FormPaddingLayout {
  final double left, right, top, verticalItemDistance;

  const FormPaddingLayout({
    this.left = 12,
    this.right = 16,
    this.top = 20,
    this.verticalItemDistance = 8,
  });
}

class MonthCalendarLayout {
  final int monthContentFlex, monthListPreviewFlex;

  final double monthHeadingHeight,
      dayRadius,
      dayRadiusHighlighted,
      dayBorderWidth,
      dayBorderWidthHighlighted,
      dayHeaderHeight,
      dayHeadingFontSize,
      weekNumberWidth,
      hasActivitiesDotDiameter;

  final EdgeInsets dayViewPadding,
      dayViewPaddingHighlighted,
      dayViewMargin,
      dayViewMarginHighlighted,
      dayHeaderPadding,
      dayContainerPadding,
      crossOverPadding,
      hasActivitiesDotPadding;

  final MonthPreviewLayout monthPreview;

  const MonthCalendarLayout({
    this.monthContentFlex = 242,
    this.monthListPreviewFlex = 229,
    this.monthHeadingHeight = 32,
    this.dayRadius = 8,
    this.dayRadiusHighlighted = 10,
    this.dayBorderWidth = 1,
    this.dayBorderWidthHighlighted = 4,
    this.dayHeaderHeight = 0,
    this.dayHeadingFontSize = 0,
    this.weekNumberWidth = 24,
    this.hasActivitiesDotDiameter = 6,
    this.dayViewPadding = const EdgeInsets.all(4),
    this.dayViewPaddingHighlighted = const EdgeInsets.all(6),
    this.dayViewMargin = const EdgeInsets.all(2),
    this.dayViewMarginHighlighted = const EdgeInsets.all(0),
    this.dayHeaderPadding = const EdgeInsets.all(0),
    this.dayContainerPadding = const EdgeInsets.all(0),
    this.crossOverPadding = const EdgeInsets.all(3),
    this.hasActivitiesDotPadding = const EdgeInsets.all(0),
    this.monthPreview = const MonthPreviewLayout(),
  });
}

class MonthPreviewLayout {
  final double monthPreviewBorderWidth,
      activityListTopPadding,
      activityListBottomPadding,
      headingHeight,
      headingFullDayActivityHeight,
      headingFullDayActivityWidth;
  final EdgeInsets monthListPreviewPadding, headingPadding;

  const MonthPreviewLayout({
    this.monthPreviewBorderWidth = 1,
    this.activityListTopPadding = 12,
    this.activityListBottomPadding = 64,
    this.headingHeight = 48,
    this.headingFullDayActivityHeight = 40,
    this.headingFullDayActivityWidth = 40,
    this.monthListPreviewPadding =
        const EdgeInsets.only(left: 8, top: 14, right: 8),
    this.headingPadding = const EdgeInsets.only(left: 12, right: 8),
  });
}
