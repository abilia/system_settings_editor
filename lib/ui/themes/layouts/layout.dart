import 'dart:ui' as ui;

import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/all.dart';

import 'package:seagull/ui/themes/layouts/components/all.dart';

part 'large_layout.dart';

part 'medium_layout.dart';

late final ui.Size screenSize =
    ui.window.physicalSize / ui.window.devicePixelRatio;

late Layout _layout = screenSize.longestSide > 1500
    ? const LargeLayout()
    : screenSize.longestSide > 1000
        ? const MediumLayout()
        : const _GoLayout();

class _GoLayout extends Layout {
  const _GoLayout() : super();
}

Layout get layout => _layout;

@visibleForTesting
set layout(Layout layout) => _layout = layout;

class Layout {
  final double radius;
  final AppBarLayout appBar;
  final ActionButtonLayout actionButton;
  final MenuPageLayout menuPage;
  final TabBarLayout tabBar;
  final ToolbarLayout toolbar;
  final NavigationBarLayout navigationBar;
  final FontSize fontSize;
  final IconLayout icon;
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
  final OngoingTabLayout ongoingFullscreen;
  final DataItemLayout dataItem;
  final ListDataItemLayout listDataItem;
  final MyPhotosLayout myPhotos;
  final ActivityPageLayout activityPage;
  final ChecklistLayout checklist;
  final NoteLayout note;
  final IconTextButtonStyle iconTextButton;
  final IconTextButtonStyle nextButton;
  final AlarmPageLayout alarmPage;
  final ScreenSaverLayout screenSaver;
  final AlarmSettingsPageLayout alarmSettingsPage;
  final ComponentsLayout components;
  final PickFieldLayout pickField;
  final EventImageLayout eventImageLayout;
  final ListFolderLayout listFolder;
  final TemplatesLayout templates;
  final BorderLayout borders;
  final LinedBorderLayout linedBorder;
  final SelectableFieldLayout selectableField;
  final CategoryLayout category;
  final RadioLayout radio;
  final SelectPictureLayout selectPicture;
  final TimeInputLayout timeInput;
  final RecordingLayout recording;
  final ArrowsLayout arrows;
  final MenuButtonLayout menuButton;
  final AgendaLayout agenda;
  final CommonCalendarLayout commonCalendar;
  final MessageLayout message;
  final FloatingActionButtonLayout fab;
  final SliderLayout slider;
  final SwitchFieldLayout switchField;
  final LoginLayout login;
  final DialogLayout dialog;
  final ActivityAlarmPreviewLayout activityPreview;
  final LogoutLayout logout;
  final SettingsLayout settings;
  final PermissionsPageLayout permissionsPage;
  final EditTimerLayout editTimer;
  final ButtonLayout button;
  final ThemeLayout theme;
  final DotLayout dot;
  final CrossOverLayout crossOver;
  final SpeechSupportPageLayout speechSupportPage;
  final StartupPageLayout startupPageLayout;
  final StarterSetDialogLayout starterSetDialog;
  final PhotoCalendarLayoutMedium photoCalendarLayout;

  const Layout({
    this.radius = 12,
    this.appBar = const AppBarLayout(),
    this.actionButton = const ActionButtonLayout(),
    this.menuPage = const MenuPageLayout(),
    this.toolbar = const ToolbarLayout(),
    this.navigationBar = const NavigationBarLayout(),
    this.tabBar = const TabBarLayout(),
    this.fontSize = const FontSize(),
    this.icon = const IconLayout(),
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
    this.ongoingFullscreen = const OngoingTabLayout(),
    this.dataItem = const DataItemLayout(),
    this.listDataItem = const ListDataItemLayout(),
    this.myPhotos = const MyPhotosLayout(),
    this.activityPage = const ActivityPageLayout(),
    this.checklist = const ChecklistLayout(),
    this.note = const NoteLayout(),
    this.iconTextButton = const IconTextButtonStyle(),
    this.nextButton = const IconTextButtonStyle(
      minimumSize: Size(150, 64),
      maximumSize: Size(150, 64),
      padding: EdgeInsets.only(left: 8),
    ),
    this.alarmPage = const AlarmPageLayout(),
    this.screenSaver = const ScreenSaverLayout(),
    this.alarmSettingsPage = const AlarmSettingsPageLayout(),
    this.components = const ComponentsLayout(),
    this.pickField = const PickFieldLayout(),
    this.eventImageLayout = const EventImageLayout(),
    this.listFolder = const ListFolderLayout(),
    this.templates = const TemplatesLayout(),
    this.borders = const BorderLayout(),
    this.linedBorder = const LinedBorderLayout(),
    this.selectableField = const SelectableFieldLayout(),
    this.category = const CategoryLayout(),
    this.radio = const RadioLayout(),
    this.selectPicture = const SelectPictureLayout(),
    this.timeInput = const TimeInputLayout(),
    this.recording = const RecordingLayout(),
    this.arrows = const ArrowsLayout(),
    this.menuButton = const MenuButtonLayout(),
    this.agenda = const AgendaLayout(),
    this.commonCalendar = const CommonCalendarLayout(),
    this.message = const MessageLayout(),
    this.fab = const FloatingActionButtonLayout(),
    this.slider = const SliderLayout(),
    this.switchField = const SwitchFieldLayout(),
    this.login = const LoginLayout(),
    this.dialog = const DialogLayout(),
    this.activityPreview = const ActivityAlarmPreviewLayout(),
    this.logout = const LogoutLayout(),
    this.settings = const SettingsLayout(),
    this.permissionsPage = const PermissionsPageLayout(),
    this.editTimer = const EditTimerLayout(),
    this.button = const ButtonLayout(),
    this.theme = const ThemeLayout(),
    this.dot = const DotLayout(),
    this.crossOver = const CrossOverLayout(),
    this.speechSupportPage = const SpeechSupportPageLayout(),
    this.startupPageLayout = const StartupPageLayout(),
    this.starterSetDialog = const StarterSetDialogLayout(),
    this.photoCalendarLayout = const PhotoCalendarLayoutMedium(),
  });

  bool get go => runtimeType == _GoLayout;
  bool get medium => runtimeType == MediumLayout;
  bool get large => runtimeType == LargeLayout;
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
  final double size, borderRadius, orangeDotInset, orangeDotRadius;

  const MenuItemButtonLayout({
    this.size = 48,
    this.borderRadius = 12,
    this.orangeDotInset = 4,
    this.orangeDotRadius = 6,
  });
}

class MyPhotosLayout {
  final double? childAspectRatio;
  final double fullScreenImageBorderRadius;
  final int crossAxisCount;
  final EdgeInsets fullScreenImagePadding;

  const MyPhotosLayout({
    this.childAspectRatio,
    this.fullScreenImageBorderRadius = 12,
    this.crossAxisCount = 3,
    this.fullScreenImagePadding = const EdgeInsets.all(12),
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

class NavigationBarLayout {
  final double height, spaceBetweeen;
  final EdgeInsets padding;

  const NavigationBarLayout({
    this.height = 84,
    this.spaceBetweeen = 8,
    this.padding = const EdgeInsets.only(
      left: 12,
      top: 8,
      right: 12,
      bottom: 12,
    ),
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

class IconLayout {
  final double tiny,
      small,
      button,
      normal,
      large,
      huge,
      doubleIconTop,
      doubleIconLeft;

  const IconLayout({
    this.tiny = 20,
    this.small = 24,
    this.button = 28,
    this.normal = 32,
    this.large = 48,
    this.huge = 96,
    this.doubleIconTop = 20,
    this.doubleIconLeft = 32,
  });
}

class FormPaddingLayout {
  final double smallVerticalItemDistance,
      verticalItemDistance,
      largeVerticalItemDistance,
      groupBottomDistance,
      groupTopDistance,
      horizontalItemDistance,
      largeHorizontalItemDistance,
      groupHorizontalDistance,
      largeGroupDistance,
      selectorDistance;

  const FormPaddingLayout({
    this.smallVerticalItemDistance = 8,
    this.verticalItemDistance = 8,
    this.largeVerticalItemDistance = 12,
    this.groupBottomDistance = 16,
    this.groupTopDistance = 24,
    this.horizontalItemDistance = 8,
    this.largeHorizontalItemDistance = 12,
    this.groupHorizontalDistance = 16,
    this.largeGroupDistance = 32,
    this.selectorDistance = 2,
  });
}

class WeekCalendarLayout {
  final _WeekDayColumnLayout selectedDay, notSelectedDay;

  final double dayDistance, headerHeight, activityDistance, categoryInset;

  final EdgeInsets crossOverDayHeadingPadding,
      crossOverActivityPadding,
      bodyPadding;

  final Radius columnRadius;

  const WeekCalendarLayout({
    this.dayDistance = 2,
    this.headerHeight = 88,
    this.activityDistance = 2,
    this.categoryInset = 0,
    this.columnRadius = const Radius.circular(8),
    this.crossOverDayHeadingPadding = const EdgeInsets.fromLTRB(3, 7, 3, 8),
    this.crossOverActivityPadding = const EdgeInsets.all(5),
    this.bodyPadding = const EdgeInsets.fromLTRB(2, 4, 2, 4),
    this.selectedDay = const _WeekDayColumnLayout(
      everyDayFlex: 82,
      weekdaysFlex: 116,
      dayColumnBorderWidth: 2,
    ),
    this.notSelectedDay = const _WeekDayColumnLayout(
      everyDayFlex: 48,
      weekdaysFlex: 64,
      dayColumnBorderWidth: 1,
    ),
  });
}

class _WeekDayColumnLayout {
  final int everyDayFlex, weekdaysFlex;

  final double activityBorderWidth,
      currentActivityBorderWidth,
      dayColumnBorderWidth;

  final BorderRadius activityRadius;

  final EdgeInsets innerDayPadding;

  const _WeekDayColumnLayout({
    required this.everyDayFlex,
    required this.weekdaysFlex,
    required this.dayColumnBorderWidth,
    this.activityBorderWidth = 1.5,
    this.currentActivityBorderWidth = 3,
    this.activityRadius = const BorderRadius.all(Radius.circular(8)),
    this.innerDayPadding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 4,
    ),
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
      hasActivitiesDotRadius;

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
    this.hasActivitiesDotRadius = 3,
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
      noSelectedDayPadding,
      crossOverPadding;

  final Size dateTextCrossOverSize;

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
    this.crossOverPadding = const EdgeInsets.all(4),
    this.dateTextCrossOverSize = const Size(163, 32),
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
      borderWidth,
      currentBorderWidth,
      timerWheelSize,
      privateIconSize,
      titleSubtitleSpacing;

  final EdgeInsets imagePadding;
  final EdgeInsets crossPadding;
  final EdgeInsets titlePadding;
  final EdgeInsets statusesPadding;
  final EdgeInsets timerWheelPadding;
  final EdgeInsets cardIconPadding;

  const EventCardLayout({
    this.height = 56,
    this.marginSmall = 6,
    this.marginLarge = 10,
    this.imageSize = 48,
    this.categorySideOffset = 43,
    this.iconSize = 18,
    this.titleImagePadding = 10,
    this.borderWidth = 1.5,
    this.currentBorderWidth = 3,
    this.timerWheelSize = 44,
    this.crossPadding = const EdgeInsets.all(4),
    this.imagePadding = const EdgeInsets.only(left: 4),
    this.titlePadding = const EdgeInsets.only(left: 8, right: 8),
    this.statusesPadding = const EdgeInsets.only(right: 8, bottom: 3),
    this.timerWheelPadding = const EdgeInsets.only(right: 5),
    this.cardIconPadding = const EdgeInsets.only(right: 4),
    this.privateIconSize = 24,
    this.titleSubtitleSpacing = 6,
  });
}

class TimerPageLayout {
  final double topInfoHeight, imageSize, imagePadding, pauseTextHeight;

  final EdgeInsets topPadding, pauseTextPadding, mainContentPadding;

  const TimerPageLayout({
    this.topInfoHeight = 126,
    this.imageSize = 96,
    this.imagePadding = 8,
    this.pauseTextHeight = 40,
    this.mainContentPadding = const EdgeInsets.fromLTRB(30, 20, 30, 0),
    this.topPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    this.pauseTextPadding = const EdgeInsets.only(top: 16),
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
      timeLineHeight,
      flarpRadius;

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
    this.flarpRadius = 8,
    this.dot = const TimepillarDotLayout(),
    this.card = const TimepillarCardLayout(),
    this.twoTimePillar = const TwoTimepillarLayout(),
  });

  TextStyle textStyle(bool isNight, double zoom) => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: fontSize * zoom,
          color: isNight ? AbiliaColors.white : AbiliaColors.black,
          fontWeight: FontWeight.w500,
          leadingDistribution: TextLeadingDistribution.even,
        ),
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
  final TimerCardLayout timer;
  final double distance, width, activityMinHeight, imageMinHeight;
  final EdgeInsets padding;

  const TimepillarCardLayout({
    this.timer = const TimerCardLayout(),
    this.width = 72,
    this.activityMinHeight = 84,
    this.padding = const EdgeInsets.all(4),
    this.distance = 12,
    this.imageMinHeight = 56,
  });
}

class TimerCardLayout {
  final double minHeigth;
  final Size wheelSize;
  final EdgeInsets wheelPadding;

  const TimerCardLayout({
    this.minHeigth = 76,
    this.wheelSize = const Size.square(44),
    this.wheelPadding = const EdgeInsets.symmetric(vertical: 4),
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
  final DividerThemeData dividerThemeData;

  const SettingsBasePageLayout({
    this.dividerThemeData = const DividerThemeData(
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
      imageNameBottomPadding,
      aspectRatio;

  const ImageArchiveLayout({
    this.imageWidth = 84,
    this.imageHeight = 86,
    this.imagePadding = 4,
    this.fullscreenImagePadding = 12,
    this.imageNameBottomPadding = 2,
    this.aspectRatio = 1,
  });
}

class LibraryPageLayout {
  final double mainAxisSpacing,
      crossAxisSpacing,
      folderIconSize,
      headerFontSize,
      childAspectRatio,
      imageHeight,
      imageWidth,
      textImageDistance,
      emptyMessageTopPadding,
      folderImageRadius;
  final int crossAxisCount;
  final EdgeInsets headerPadding,
      folderImagePadding,
      notePadding,
      contentPadding;

  const LibraryPageLayout({
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.crossAxisCount = 3,
    this.headerPadding = const EdgeInsets.fromLTRB(16, 12, 0, 3),
    this.folderImagePadding = const EdgeInsets.fromLTRB(10, 28, 10, 16),
    this.notePadding = const EdgeInsets.fromLTRB(5, 9, 5, 6),
    this.contentPadding = const EdgeInsets.all(4),
    this.folderIconSize = 86,
    this.headerFontSize = 20,
    this.childAspectRatio = 1,
    this.imageHeight = 86,
    this.imageWidth = 86,
    this.textImageDistance = 2,
    this.emptyMessageTopPadding = 60,
    this.folderImageRadius = 4,
  });

  TextStyle headerStyle() => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: headerFontSize,
          color: AbiliaColors.black,
          fontWeight: FontWeight.w500,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
}

class OngoingTabLayout {
  final OngoingActivityLayout activity;
  final double height;
  final EdgeInsets padding;

  const OngoingTabLayout({
    this.height = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
    this.activity = const OngoingActivityLayout(),
  });
}

class OngoingActivityLayout {
  final double border, activeBorder;
  final Size arrowSize;
  final EdgeInsets padding, selectedPadding;

  final Radius arrowPointRadius;
  final OngoingCategoryDotLayout dot;

  const OngoingActivityLayout({
    this.activeBorder = 2,
    this.border = 1.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    this.selectedPadding = const EdgeInsets.symmetric(vertical: 2),
    this.dot = const OngoingCategoryDotLayout(),
    this.arrowSize = const Size(32, 14),
    this.arrowPointRadius = const Radius.circular(4),
  });
}

class OngoingCategoryDotLayout {
  final double innerRadius, outerRadius, offset, selectedOffset;

  const OngoingCategoryDotLayout({
    this.innerRadius = 4,
    this.outerRadius = 5,
    this.offset = 3,
    this.selectedOffset = 5,
  });
}

class DataItemLayout {
  final double borderRadius;
  final _DataItemPictureLayout picture;

  const DataItemLayout({
    this.borderRadius = 12,
    this.picture = const _DataItemPictureLayout(),
  });
}

class _DataItemPictureLayout {
  final double stickerIconSize;
  final Size stickerSize;
  final EdgeInsets imagePadding, titlePadding;

  const _DataItemPictureLayout({
    this.stickerIconSize = 16,
    this.stickerSize = const Size(32, 32),
    this.imagePadding = const EdgeInsets.only(left: 12, right: 12, bottom: 3),
    this.titlePadding =
        const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 2),
  });
}

/// Called DataItem (list) in Figma
class ListDataItemLayout {
  final EdgeInsets folderPadding, imagePadding, textAndSubtitlePadding;
  final double iconSize;
  final double? secondaryTextHeight;

  const ListDataItemLayout({
    this.folderPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.imagePadding = const EdgeInsets.only(left: 4, right: 8),
    this.textAndSubtitlePadding = const EdgeInsets.only(top: 3, bottom: 7),
    this.iconSize = 24,
    this.secondaryTextHeight,
  });
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
      minTimeBoxWidth,
      timeBoxCurrentBorderWidth,
      timeBoxFutureBorderWidth;

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
        textStyle: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w400,
          height: titleLineHeight / titleFontSize,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );

  const ActivityPageLayout({
    this.topInfoHeight = 126,
    this.timeRowPadding = const EdgeInsets.only(bottom: 8),
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
    this.timeCrossOverSize = const Size(64, 38),
    this.timeBoxPadding = const EdgeInsets.all(8),
    this.timeBoxSize = const Size(92, 52),
    this.minTimeBoxWidth = 72,
    this.timeBoxCurrentBorderWidth = 2,
    this.timeBoxFutureBorderWidth = 1,
  });
}

class ChecklistLayout {
  final ChecklistQuestionLayout question;
  final EdgeInsets listPadding, addNewQButtonPadding, addNewQIconPadding;
  const ChecklistLayout({
    this.question = const ChecklistQuestionLayout(),
    this.listPadding = const EdgeInsets.all(12),
    this.addNewQButtonPadding = const EdgeInsets.fromLTRB(12, 8, 12, 12),
    this.addNewQIconPadding = const EdgeInsets.symmetric(horizontal: 12),
  });
}

class ChecklistQuestionLayout {
  final EdgeInsets imagePadding, titlePadding, iconPadding;
  final double imageSize, viewHeight, fontSize, lineHeight;

  const ChecklistQuestionLayout({
    this.imagePadding = const EdgeInsets.fromLTRB(6, 4, 0, 4),
    this.titlePadding = const EdgeInsets.fromLTRB(8, 10, 0, 10),
    this.iconPadding = const EdgeInsets.fromLTRB(14, 12, 12, 12),
    this.imageSize = 40,
    this.viewHeight = 48,
    this.fontSize = 16,
    this.lineHeight = 28,
  });

  TextStyle get textStyle => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: fontSize,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
          height: lineHeight / fontSize,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
}

class NoteLayout {
  final EdgeInsets notePadding;
  final double lineOffset;

  const NoteLayout({
    this.notePadding = const EdgeInsets.fromLTRB(18, 10, 16, 24),
    this.lineOffset = 2,
  });
}

class IconTextButtonStyle {
  final Size minimumSize, maximumSize;
  final EdgeInsets padding;
  final double iconTextSpacing;

  const IconTextButtonStyle({
    this.minimumSize = const Size(172, 64),
    this.maximumSize = const Size(double.infinity, 64),
    this.iconTextSpacing = 8,
    this.padding = const EdgeInsets.only(right: 8),
  });
}

class AlarmPageLayout {
  final EdgeInsets alarmClockPadding;

  const AlarmPageLayout({
    this.alarmClockPadding =
        const EdgeInsets.only(top: 4, bottom: 4, right: 16),
  });
}

class ScreenSaverLayout {
  final double clockHeight,
      clockSeparation,
      digitalClockTextSize,
      digitalClockLineHeight;
  final EdgeInsets clockPadding, titleBarPadding;

  const ScreenSaverLayout({
    this.clockHeight = 288,
    this.clockSeparation = 48,
    this.digitalClockTextSize = 80,
    this.digitalClockLineHeight = 93.75,
    this.titleBarPadding = const EdgeInsets.only(top: 24),
    this.clockPadding = const EdgeInsets.only(top: 138),
  });

  TextStyle get digitalClockTextStyle => GoogleFonts.roboto(
          textStyle: TextStyle(
        fontSize: digitalClockTextSize,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        color: AbiliaColors.white,
        height: digitalClockLineHeight / digitalClockTextSize,
        leadingDistribution: TextLeadingDistribution.even,
      ));
}

class AlarmSettingsPageLayout {
  final double playButtonSeparation;
  final EdgeInsets defaultPadding, topPadding, bottomPadding, dividerPadding;

  const AlarmSettingsPageLayout({
    this.playButtonSeparation = 12,
    this.defaultPadding = const EdgeInsets.fromLTRB(12, 16, 20, 0),
    this.topPadding = const EdgeInsets.fromLTRB(12, 24, 20, 0),
    this.bottomPadding = const EdgeInsets.fromLTRB(12, 16, 20, 64),
    this.dividerPadding = const EdgeInsets.only(top: 16, bottom: 8),
  });
}

class ComponentsLayout {
  final EdgeInsets subHeadingPadding;

  const ComponentsLayout({
    this.subHeadingPadding = const EdgeInsets.only(bottom: 8),
  });
}

class PickFieldLayout {
  final double height;
  final Size leadingSize;
  final EdgeInsets padding, leadingPadding, imagePadding;

  const PickFieldLayout({
    this.height = 56,
    this.leadingSize = const Size(48, 48),
    this.padding = const EdgeInsets.only(left: 12, right: 12),
    this.imagePadding = const EdgeInsets.only(right: 8),
    this.leadingPadding = const EdgeInsets.only(right: 12),
  });
}

class EventImageLayout {
  final EdgeInsets fallbackCrossPadding, fallbackCheckPadding;

  const EventImageLayout({
    this.fallbackCrossPadding = const EdgeInsets.all(4),
    this.fallbackCheckPadding = const EdgeInsets.all(8),
  });
}

class ListFolderLayout {
  final double iconSize, imageBorderRadius;
  final EdgeInsets margin, imagePadding;

  const ListFolderLayout({
    this.iconSize = 42,
    this.imageBorderRadius = 2,
    this.imagePadding = const EdgeInsets.fromLTRB(6, 16, 6, 11),
    this.margin = const EdgeInsets.only(left: 2, right: 6),
  });
}

class BorderLayout {
  final double thin, medium;

  const BorderLayout({
    this.thin = 1,
    this.medium = 2,
  });
}

class LinedBorderLayout {
  final double dashSize;

  const LinedBorderLayout({this.dashSize = 4});
}

class SelectableFieldLayout {
  final double position,
      size,
      height,
      textLeftPadding,
      textRightPadding,
      textTopPadding;
  final EdgeInsets padding;
  final EdgeInsets boxPadding;

  const SelectableFieldLayout({
    this.height = 48,
    this.position = -6,
    this.size = 24,
    this.textLeftPadding = 12,
    this.textRightPadding = 26,
    this.textTopPadding = 10,
    this.padding = const EdgeInsets.all(4),
    this.boxPadding = const EdgeInsets.all(3),
  });
}

class CategoryLayout {
  final double height,
      radius,
      startPadding,
      endPadding,
      emptySize,
      topMargin,
      imageDiameter,
      noColorsImageSize;
  final EdgeInsets radioPadding, imagePadding;

  const CategoryLayout({
    this.height = 44,
    this.radius = 100,
    this.startPadding = 8,
    this.endPadding = 4,
    this.emptySize = 16,
    this.topMargin = 4,
    this.imageDiameter = 36,
    this.noColorsImageSize = 30,
    this.radioPadding = const EdgeInsets.all(8),
    this.imagePadding = const EdgeInsets.all(3),
  });
}

class RadioLayout {
  final double outerRadius, innerRadius;

  const RadioLayout({
    this.outerRadius = 11.5,
    this.innerRadius = 8.5,
  });
}

class SelectPictureLayout {
  final double imageSize, imageSizeLarge, padding, paddingLarge;
  final EdgeInsets removeButtonPadding;

  const SelectPictureLayout({
    this.imageSize = 84,
    this.imageSizeLarge = 119,
    this.padding = 4,
    this.paddingLarge = 5.67,
    this.removeButtonPadding = const EdgeInsets.fromLTRB(8, 6, 8, 6),
  });
}

class TimeInputLayout {
  final double width,
      height,
      amPmHeight,
      amPmWidth,
      timeDashAlignValue,
      amPmDistance,
      inputKeyboardDistance,
      keyboardButtonHeight,
      keyboardButtonWidth,
      keyboardButtonPadding;
  final EdgeInsets headerClockPadding;

  const TimeInputLayout({
    this.width = 120,
    this.height = 64,
    this.amPmHeight = 48,
    this.amPmWidth = 59,
    this.timeDashAlignValue = 14,
    this.amPmDistance = 2,
    this.inputKeyboardDistance = 44,
    this.headerClockPadding = const EdgeInsets.only(right: 16),
    this.keyboardButtonHeight = 48,
    this.keyboardButtonWidth = 80,
    this.keyboardButtonPadding = 8,
  });
}

class RecordingLayout {
  final double trackHeight, thumbRadius;
  final EdgeInsets padding;

  const RecordingLayout({
    this.trackHeight = 4,
    this.thumbRadius = 12,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 32,
    ),
  });
}

class ArrowsLayout {
  final double collapseMargin, radius, size;

  const ArrowsLayout({
    this.collapseMargin = 2,
    this.radius = 100,
    this.size = 48,
  });
}

class MenuButtonLayout {
  final double dotPosition;

  const MenuButtonLayout({
    this.dotPosition = -3,
  });
}

class AgendaLayout {
  final double topPadding, bottomPadding, sliverTopPadding;

  const AgendaLayout({
    this.topPadding = 60,
    this.bottomPadding = 125,
    this.sliverTopPadding = 96,
  });
}

class CommonCalendarLayout {
  final double fullDayStackDistance, goToNowButtonTop;

  final EdgeInsets fullDayPadding, fullDayButtonPadding;

  const CommonCalendarLayout({
    this.fullDayStackDistance = 4,
    this.goToNowButtonTop = 32,
    this.fullDayPadding = const EdgeInsets.all(12),
    this.fullDayButtonPadding = const EdgeInsets.fromLTRB(10, 4, 4, 4),
  });
}

class MessageLayout {
  final EdgeInsets padding;

  const MessageLayout({
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 20,
    ),
  });
}

class SliderLayout {
  final double defaultHeight,
      leftPadding,
      rightPadding,
      iconRightPadding,
      thumbRadius,
      elevation,
      pressedElevation,
      outerBorder,
      trackHeight;

  const SliderLayout({
    this.defaultHeight = 56,
    this.leftPadding = 12,
    this.rightPadding = 4,
    this.iconRightPadding = 12,
    this.thumbRadius = 12,
    this.elevation = 1,
    this.pressedElevation = 2,
    this.outerBorder = 2,
    this.trackHeight = 4,
  });
}

class SwitchFieldLayout {
  final double height, toggleSize;
  final EdgeInsets padding;

  const SwitchFieldLayout({
    this.height = 56,
    this.toggleSize = 48,
    this.padding = const EdgeInsets.only(left: 12.0, right: 4.0),
  });
}

class LoginLayout {
  final double topFormDistance, logoSize, progressWidth, termsPadding;
  final EdgeInsets createAccountPadding, loginButtonPadding;

  const LoginLayout({
    this.topFormDistance = 32,
    this.logoSize = 64,
    this.progressWidth = 6,
    this.termsPadding = 48,
    this.createAccountPadding = const EdgeInsets.fromLTRB(16, 8, 16, 32),
    this.loginButtonPadding = const EdgeInsets.fromLTRB(16, 32, 16, 0),
  });
}

class DialogLayout {
  final double iconTextDistance, fullscreenTop, fullscreenIconDistance;

  const DialogLayout({
    this.iconTextDistance = 24,
    this.fullscreenTop = 128,
    this.fullscreenIconDistance = 80,
  });
}

class ActivityAlarmPreviewLayout {
  final double radius, height, activityHeight, activityWidth;

  const ActivityAlarmPreviewLayout({
    this.radius = 4,
    this.height = 256,
    this.activityHeight = 800,
    this.activityWidth = 450,
  });
}

class LogoutLayout {
  final double profilePictureSize, profileDistance, topDistance;

  const LogoutLayout({
    this.profilePictureSize = 84,
    this.profileDistance = 24,
    this.topDistance = 64,
  });
}

class SettingsLayout {
  final double clockHeight,
      clockWidth,
      previewTimePillarWidth,
      intervalStepperWidth,
      monthPreviewHeight,
      monthPreviewHeaderHeight,
      weekCalendarHeight,
      weekCalendarHeadingHeight,
      weekDayHeight,
      permissionsDotPosition;

  final EdgeInsets monthDaysPadding, weekDaysPadding, textToSpeechPadding;

  const SettingsLayout({
    this.clockHeight = 90,
    this.clockWidth = 72,
    this.previewTimePillarWidth = 138,
    this.intervalStepperWidth = 230,
    this.monthPreviewHeight = 96,
    this.monthPreviewHeaderHeight = 32,
    this.weekCalendarHeight = 148,
    this.weekCalendarHeadingHeight = 44,
    this.weekDayHeight = 86,
    this.permissionsDotPosition = 8,
    this.monthDaysPadding = const EdgeInsets.only(left: 4.0, right: 4),
    this.weekDaysPadding = const EdgeInsets.symmetric(horizontal: 2.0),
    this.textToSpeechPadding = const EdgeInsets.only(left: 8, right: 4),
  });
}

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

class EditTimerLayout {
  final double inputTimeWidth, inputTimePadding;
  final EdgeInsets wheelPadding;

  const EditTimerLayout({
    this.inputTimeWidth = 120,
    this.inputTimePadding = 16,
    this.wheelPadding = const EdgeInsets.only(top: 11),
  });
}

class ButtonLayout {
  final double baseButtonMinHeight, secondaryActionButtonMinSize;
  final Size redButtonMinSize;
  final EdgeInsets textButtonInsets,
      actionButtonIconTextPadding,
      startBasicTimerPadding;

  const ButtonLayout({
    this.baseButtonMinHeight = 64,
    this.redButtonMinSize = const Size(0, 48),
    this.secondaryActionButtonMinSize = 40,
    this.textButtonInsets =
        const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    this.actionButtonIconTextPadding =
        const EdgeInsets.fromLTRB(10, 10, 20, 10),
    this.startBasicTimerPadding = const EdgeInsets.fromLTRB(0, 4, 4, 4),
  });
}

class ThemeLayout {
  final double circleRadius;
  final EdgeInsets inputPadding;

  const ThemeLayout({
    this.circleRadius = 24,
    this.inputPadding =
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  });
}

class DotLayout {
  final double bigDotSize, miniDotSize, bigDotPadding;

  const DotLayout({
    this.bigDotSize = 28,
    this.miniDotSize = 4,
    this.bigDotPadding = 6,
  });
}

class FloatingActionButtonLayout {
  final EdgeInsets padding;

  const FloatingActionButtonLayout({this.padding = const EdgeInsets.all(16)});
}

class CrossOverLayout {
  final double strokeWidth;

  const CrossOverLayout({
    this.strokeWidth = 2,
  });
}

class SpeechSupportPageLayout {
  final double loaderStrokeWidth, loaderSize;
  const SpeechSupportPageLayout({
    this.loaderStrokeWidth = 6,
    this.loaderSize = 56,
  });
}
