import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

part 'go_layout.dart';

part 'large_layout.dart';

part 'medium_layout.dart';

final Layout layout = Device.screenSize.longestSide > 1500
    ? const _LargeLayout()
    : Device.screenSize.longestSide > 1000
        ? const _MediumLayout()
        : const _GoLayout();

class Layout {
  final AppBarLayout appBar;
  final ActionButtonLayout actionButton;
  final MenuPageLayout menuPage;
  final TabBarLayout tabBar;
  final ToolbarLayout toolbar;
  final FontSize fontSize;
  final IconSize iconSize;
  final ClockLayout clock;
  final FormPaddingLayout formPadding;
  final WeekCalendarLayout weekCalendar;
  final MonthCalendarLayout monthCalendar;
  final EventCardLayout eventCard;
  final TimepillarLayout timePillar;
  final TimerPageLayout timerPage;
  final SettingsBasePageLayout settingsBasePage;
  final DefaultTextInputPageLayout defaultTextInputPage;
  final ImageArchiveLayout imageArchive;
  final LibraryPageLayout libraryPage;
  final ActivityPageLayout activityPage;
  final CheckListLayout checkList;
  final NoteLayout note;

  const Layout({
    this.appBar = const AppBarLayout(),
    this.actionButton = const ActionButtonLayout(),
    this.menuPage = const MenuPageLayout(),
    this.toolbar = const ToolbarLayout(),
    this.tabBar = const TabBarLayout(),
    this.fontSize = const FontSize(),
    this.iconSize = const IconSize(),
    this.clock = const ClockLayout(),
    this.formPadding = const FormPaddingLayout(),
    this.weekCalendar = const WeekCalendarLayout(),
    this.monthCalendar = const MonthCalendarLayout(),
    this.eventCard = const EventCardLayout(),
    this.timePillar = const TimepillarLayout(),
    this.timerPage = const TimerPageLayout(),
    this.settingsBasePage = const SettingsBasePageLayout(),
    this.defaultTextInputPage = const DefaultTextInputPageLayout(),
    this.imageArchive = const ImageArchiveLayout(),
    this.libraryPage = const LibraryPageLayout(),
    this.activityPage = const ActivityPageLayout(),
    this.checkList = const CheckListLayout(),
    this.note = const NoteLayout(),
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

class MenuPageLayout {
  final EdgeInsets padding;
  final double crossAxisSpacing, mainAxisSpacing;
  final int crossAxisCount;

  final MenuItemButtonLayout menuItemButton;

  const MenuPageLayout({
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    this.crossAxisSpacing = 7.5,
    this.mainAxisSpacing = 7,
    this.crossAxisCount = 3,
    this.menuItemButton = const MenuItemButtonLayout(),
  });
}

class MenuItemButtonLayout {
  final double size, borderRadius, orangeDotInset;

  const MenuItemButtonLayout({
    this.size = 48,
    this.borderRadius = 12,
    this.orangeDotInset = 4,
  });
}

class ToolbarLayout {
  final double height, horizontalPadding, bottomPadding;

  const ToolbarLayout({
    this.height = 64,
    this.horizontalPadding = 16,
    this.bottomPadding = 0,
  });
}

class TabBarLayout {
  final TabItemLayout item;
  final double height, bottomPadding;

  const TabBarLayout({
    this.item = const TabItemLayout(),
    this.height = 64,
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

class WeekCalendarLayout {
  final double activityBorderWidth, currentActivityBorderWidth;

  const WeekCalendarLayout({
    this.activityBorderWidth = 1.5,
    this.currentActivityBorderWidth = 3,
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
      fullDayActivityFontSize,
      weekNumberWidth,
      hasActivitiesDotDiameter;

  final EdgeInsets dayViewPadding,
      dayViewPaddingHighlighted,
      dayViewMargin,
      dayViewMarginHighlighted,
      dayHeaderPadding,
      dayContainerPadding,
      crossOverPadding,
      hasActivitiesDotPadding,
      activityTextContentPadding;

  final MonthPreviewLayout monthPreview;

  const MonthCalendarLayout({
    this.monthContentFlex = 242,
    this.monthListPreviewFlex = 229,
    this.monthHeadingHeight = 32,
    this.dayRadius = 8,
    this.dayRadiusHighlighted = 10,
    this.dayBorderWidth = 1,
    this.dayBorderWidthHighlighted = 4,
    this.dayHeaderHeight = 24,
    this.dayHeadingFontSize = 14,
    this.fullDayActivityFontSize = 12,
    this.weekNumberWidth = 24,
    this.hasActivitiesDotDiameter = 6,
    this.dayViewPadding = const EdgeInsets.all(4),
    this.dayViewPaddingHighlighted = const EdgeInsets.all(6),
    this.dayViewMargin = const EdgeInsets.all(2),
    this.dayViewMarginHighlighted = const EdgeInsets.all(0),
    this.dayHeaderPadding = const EdgeInsets.only(left: 4, top: 7, right: 4),
    this.dayContainerPadding =
        const EdgeInsets.only(left: 5, top: 3, right: 5, bottom: 5),
    this.crossOverPadding = const EdgeInsets.all(3),
    this.hasActivitiesDotPadding = const EdgeInsets.all(0),
    this.activityTextContentPadding = const EdgeInsets.all(3),
    this.monthPreview = const MonthPreviewLayout(),
  });
}

class MonthPreviewLayout {
  final double monthPreviewBorderWidth,
      activityListTopPadding,
      activityListBottomPadding,
      headingHeight,
      headingFullDayActivityHeight,
      headingFullDayActivityWidth,
      headingButtonIconSize;

  final EdgeInsets monthListPreviewPadding,
      headingPadding,
      noSelectedDayPadding;

  const MonthPreviewLayout({
    this.monthPreviewBorderWidth = 1,
    this.activityListTopPadding = 12,
    this.activityListBottomPadding = 64,
    this.headingHeight = 48,
    this.headingFullDayActivityHeight = 40,
    this.headingFullDayActivityWidth = 40,
    this.headingButtonIconSize = 24,
    this.monthListPreviewPadding =
        const EdgeInsets.only(left: 8, top: 14, right: 8),
    this.headingPadding = const EdgeInsets.only(left: 12, right: 8),
    this.noSelectedDayPadding = const EdgeInsets.only(top: 32),
  });
}

class EventCardLayout {
  final double height,
      marginSmall,
      marginLarge,
      imageSize,
      categorySideOffset,
      iconSize,
      titleImagePadding,
      crossOverStrokeWidth,
      borderWidth,
      currentBorderWidth,
      timerWheelSize;

  final EdgeInsets imagePadding;
  final EdgeInsets crossPadding;
  final EdgeInsets titlePadding;
  final EdgeInsets statusesPadding;
  final EdgeInsets timerWheelPadding;

  const EventCardLayout({
    this.height = 56,
    this.marginSmall = 6,
    this.marginLarge = 10,
    this.imageSize = 48,
    this.categorySideOffset = 43,
    this.iconSize = 18,
    this.titleImagePadding = 10,
    this.crossOverStrokeWidth = 2,
    this.borderWidth = 1.5,
    this.currentBorderWidth = 3,
    this.timerWheelSize = 44,
    this.crossPadding = const EdgeInsets.all(4),
    this.imagePadding = const EdgeInsets.only(left: 4),
    this.titlePadding =
        const EdgeInsets.only(left: 8, top: 6, right: 8, bottom: 2),
    this.statusesPadding = const EdgeInsets.only(right: 8, bottom: 3),
    this.timerWheelPadding = const EdgeInsets.only(right: 8),
  });
}

class TimerPageLayout {
  final double topInfoHeight, imageSize, imagePadding, mainContentPadding;

  final EdgeInsets bodyPadding, topPadding;

  const TimerPageLayout({
    this.topInfoHeight = 126,
    this.imageSize = 96,
    this.mainContentPadding = 32,
    this.imagePadding = 8,
    this.bodyPadding = const EdgeInsets.all(12),
    this.topPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
  });
}

class TimepillarLayout {
  final double fontSize,
      width,
      padding,
      hourPadding,
      hourLineWidth,
      topMargin,
      bottomMargin,
      timeLineHeight;

  final TimepillarDotLayout dot;
  final TimepillarCardLayout card;
  final TwoTimepillarLayout twoTimePillar;

  const TimepillarLayout({
    this.fontSize = 20,
    this.width = 42,
    this.padding = 10,
    this.hourPadding = 1,
    this.hourLineWidth = 1,
    this.topMargin = 96,
    this.bottomMargin = 64,
    this.timeLineHeight = 2,
    this.dot = const TimepillarDotLayout(),
    this.card = const TimepillarCardLayout(),
    this.twoTimePillar = const TwoTimepillarLayout(),
  });

  TextStyle textStyle(bool isNight, double zoom) => GoogleFonts.roboto(
        fontSize: fontSize * zoom,
        color: isNight ? AbiliaColors.white : AbiliaColors.black,
        fontWeight: FontWeight.w500,
      );
}

class TimepillarDotLayout {
  final double size, padding, distance;

  const TimepillarDotLayout({
    this.size = 10,
    this.padding = 3,
  }) : distance = size + padding;
}

class TimepillarCardLayout {
  final double padding, width, minHeight, margin, imageHeightMin;

  const TimepillarCardLayout({
    this.width = 72,
    this.minHeight = 84,
    this.margin = 4,
    this.padding = 12,
    this.imageHeightMin = 56,
  });
}

class TwoTimepillarLayout {
  final double verticalMargin, nightMargin, radius;

  const TwoTimepillarLayout({
    this.verticalMargin = 24,
    this.radius = 9,
    this.nightMargin = 4,
  });
}

class SettingsBasePageLayout {
  final EdgeInsets itemPadding, listPadding;
  final DividerThemeData dividerThemeData;

  const SettingsBasePageLayout({
    this.itemPadding = const EdgeInsets.fromLTRB(12, 8, 16, 0),
    this.listPadding = const EdgeInsets.symmetric(vertical: 16),
    this.dividerThemeData = const DividerThemeData(
      space: 32,
      thickness: 1,
      endIndent: 12,
    ),
  });
}

class DefaultTextInputPageLayout {
  final double textFieldActionButtonSpacing;

  const DefaultTextInputPageLayout({
    this.textFieldActionButtonSpacing = 12,
  });
}

class ImageArchiveLayout {
  final double imageWidth,
      imageHeight,
      imagePadding,
      fullscreenImagePadding,
      imageNameBottomPadding;

  const ImageArchiveLayout({
    this.imageWidth = 84,
    this.imageHeight = 86,
    this.imagePadding = 4,
    this.fullscreenImagePadding = 12,
    this.imageNameBottomPadding = 2,
  });
}

class LibraryPageLayout {
  final double mainAxisSpacing,
      crossAxisSpacing,
      folderIconSize,
      headerFontSize,
      childAspectRatio;
  final int crossAxisCount;
  final EdgeInsets headerPadding, folderImagePadding;

  const LibraryPageLayout({
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.crossAxisCount = 3,
    this.headerPadding = const EdgeInsets.fromLTRB(16, 12, 0, 3),
    this.folderImagePadding = const EdgeInsets.fromLTRB(10, 28, 10, 16),
    this.folderIconSize = 86,
    this.headerFontSize = 20,
    this.childAspectRatio = 110 / 112,
  });

  TextStyle headerStyle() => GoogleFonts.roboto(
        fontSize: headerFontSize,
        color: AbiliaColors.black,
        fontWeight: FontWeight.w500,
      );
}

class ActivityPageLayout {
  final double titleFontSize,
      titleLineHeight,
      titleImageHorizontalSpacing,
      topInfoHeight,
      checkButtonHeight,
      dividerHeight,
      dividerIndentation,
      dashWidth,
      dashSpacing,
      minTimeBoxWidth;

  final Size timeBoxSize, timeCrossOverSize;

  final EdgeInsets timeRowPadding,
      timeBoxPadding,
      topInfoPadding,
      imagePadding,
      verticalInfoPaddingCheckable,
      verticalInfoPaddingNonCheckable,
      horizontalInfoPadding,
      checkButtonPadding,
      checkButtonContentPadding,
      checklistPadding;

  TextStyle titleStyle() => GoogleFonts.roboto(
      fontSize: titleFontSize,
      fontWeight: FontWeight.w400,
      height: titleLineHeight / titleFontSize);

  const ActivityPageLayout({
    this.timeCrossOverSize = const Size(64, 38),
    this.timeBoxSize = const Size(92, 52),
    this.topInfoHeight = 126,
    this.timeRowPadding = const EdgeInsets.only(bottom: 8),
    this.timeBoxPadding = const EdgeInsets.all(8),
    this.topInfoPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    this.titleImageHorizontalSpacing = 8,
    this.imagePadding = const EdgeInsets.fromLTRB(12, 0, 12, 12),
    this.verticalInfoPaddingCheckable =
        const EdgeInsets.only(top: 16, bottom: 10),
    this.verticalInfoPaddingNonCheckable =
        const EdgeInsets.only(top: 16, bottom: 12),
    this.horizontalInfoPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.checkButtonPadding = const EdgeInsets.only(bottom: 16),
    this.checkButtonContentPadding = const EdgeInsets.fromLTRB(10, 10, 20, 10),
    this.checklistPadding = const EdgeInsets.fromLTRB(18, 12, 12, 0),
    this.titleFontSize = 24,
    this.titleLineHeight = 28.13,
    this.checkButtonHeight = 48,
    this.dividerHeight = 1,
    this.dividerIndentation = 12,
    this.dashWidth = 7,
    this.dashSpacing = 8,
    this.minTimeBoxWidth = 72,
  });
}

class CheckListLayout {
  final EdgeInsets questionViewPadding,
      questionImagePadding,
      questionTitlePadding,
      questionIconPadding,
      addNewQButtonPadding,
      addNewQIconPadding,
      questionListPadding;

  final double questionImageSize,
      questionViewHeight,
      dividerHeight,
      dividerIndentation;

  const CheckListLayout({
    this.questionViewPadding = const EdgeInsets.only(bottom: 6),
    this.questionImagePadding = const EdgeInsets.only(left: 6),
    this.questionTitlePadding = const EdgeInsets.only(left: 8, right: 14),
    this.questionIconPadding = const EdgeInsets.only(right: 12),
    this.addNewQButtonPadding = const EdgeInsets.fromLTRB(12, 8, 12, 12),
    this.addNewQIconPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.questionListPadding = const EdgeInsets.fromLTRB(12, 12, 12, 0),
    this.questionImageSize = 40,
    this.questionViewHeight = 48,
    this.dividerHeight = 1,
    this.dividerIndentation = 12,
  });
}

class NoteLayout {
  final EdgeInsets notePadding;

  const NoteLayout({
    this.notePadding = const EdgeInsets.fromLTRB(18, 10, 16, 24),
  });
}
