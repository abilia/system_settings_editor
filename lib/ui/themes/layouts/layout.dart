import 'dart:ui' as ui;

import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/all.dart';

part 'large_layout.dart';

part 'medium_layout.dart';

final ui.Size screenSize = ui.window.physicalSize / ui.window.devicePixelRatio;

Layout _layout = screenSize.longestSide > 1500
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
  final TimepillarLayout timepillar;
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
  final ScreensaverLayout screensaver;
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
  final StartupPageLayout startupPage;
  final StarterSetDialogLayout starterSetDialog;
  final PhotoCalendarLayoutMedium photoCalendarLayout;
  final SupportPersonLayout supportPerson;
  final CodeProtectLayoutMedium codeProtect;
  final SelectorLayout selector;
  final ProgressIndicatorLayout progressIndicator;
  final AboutLayout about;

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
    this.timepillar = const TimepillarLayout(),
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
    this.screensaver = const ScreensaverLayout(),
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
    this.startupPage = const StartupPageLayout(),
    this.starterSetDialog = const StarterSetDialogLayout(),
    this.photoCalendarLayout = const PhotoCalendarLayoutMedium(),
    this.supportPerson = const SupportPersonLayout(),
    this.codeProtect = const CodeProtectLayoutMedium(),
    this.selector = const SelectorLayout(),
    this.progressIndicator = const ProgressIndicatorLayout(),
    this.about = const AboutLayout(),
  });

  bool get go => runtimeType == _GoLayout;
  bool get medium => runtimeType == MediumLayout;
  bool get large => runtimeType == LargeLayout;
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
  final EdgeInsets padding;

  const TabItemLayout({
    this.width = 64,
    this.border = 1,
    this.padding = const EdgeInsets.only(left: 4, top: 4, right: 4),
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
  final DataItemPictureLayout picture;

  const DataItemLayout({
    this.borderRadius = 12,
    this.picture = const DataItemPictureLayout(),
  });
}

class DataItemPictureLayout {
  final double stickerIconSize;
  final Size stickerSize;
  final EdgeInsets imagePadding, titlePadding;

  const DataItemPictureLayout({
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

class ScreensaverLayout {
  final double clockHeight,
      clockSeparation,
      digitalClockTextSize,
      digitalClockLineHeight;
  final EdgeInsets clockPadding, titleBarPadding;

  const ScreensaverLayout({
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
  final double topFormDistance, logoSize, termsPadding, logoHeight;
  final EdgeInsets createAccountPadding, loginButtonPadding;

  const LoginLayout({
    this.topFormDistance = 32,
    this.logoSize = 64,
    this.termsPadding = 48,
    this.logoHeight = 64,
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
  final double loaderSize;
  const SpeechSupportPageLayout({
    this.loaderSize = 56,
  });
}
