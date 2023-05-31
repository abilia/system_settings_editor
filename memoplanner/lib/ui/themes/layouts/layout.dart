import 'dart:ui';

import 'package:memoplanner/ui/all.dart';

part 'layout_large.dart';
part 'layout_medium.dart';

bool get isLargeScreen => _screenSize.shortestSide > 1000;

bool get isMediumScreen => _screenSize.shortestSide > 600;

Layout get layout => _layout;

FlutterView get deviceView =>
    WidgetsBinding.instance.platformDispatcher.views.first;

Size _screenSize = deviceView.physicalSize / deviceView.devicePixelRatio;
Layout _layout = _getLayout();

@visibleForTesting
set screenSize(Size screenSize) {
  _screenSize = screenSize;
  _layout = _getLayout();
}

Layout _getLayout() => isLargeScreen
    ? const LargeLayout()
    : isMediumScreen
        ? const MediumLayout()
        : const GoLayout();

class GoLayout extends Layout {
  const GoLayout() : super();
}

abstract class Layout {
  final TemplatesLayout templates;
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
  final EditTimerPageLayout editTimer;
  final ButtonLayout button;
  final ThemeLayout theme;
  final DotLayout dot;
  final CrossOverLayout crossOver;
  final SpeechSupportPageLayout speechSupportPage;
  final StartupPageLayout startupPage;
  final StarterSetDialogLayout starterSetDialog;
  final TermsOfUseDialogLayout termsOfUseDialog;
  final ResetDeviceDialogLayout resetDeviceDialog;
  final PhotoCalendarLayoutMedium photoCalendarLayout;
  final SupportPersonLayout supportPerson;
  final CodeProtectLayoutMedium codeProtect;
  final SelectorLayout selector;
  final ProgressIndicatorLayout progressIndicator;
  final AboutLayout about;
  final InfoRowLayout infoRow;

  const Layout({
    this.templates = const TemplatesLayout(),
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
    this.editTimer = const EditTimerPageLayout(),
    this.button = const ButtonLayout(),
    this.theme = const ThemeLayout(),
    this.dot = const DotLayout(),
    this.crossOver = const CrossOverLayout(),
    this.speechSupportPage = const SpeechSupportPageLayout(),
    this.startupPage = const StartupPageLayout(),
    this.starterSetDialog = const StarterSetDialogLayout(),
    this.termsOfUseDialog = const TermsOfUseDialogLayout(),
    this.resetDeviceDialog = const ResetDeviceDialogLayout(),
    this.photoCalendarLayout = const PhotoCalendarLayoutMedium(),
    this.supportPerson = const SupportPersonLayout(),
    this.codeProtect = const CodeProtectLayoutMedium(),
    this.selector = const SelectorLayout(),
    this.progressIndicator = const ProgressIndicatorLayout(),
    this.about = const AboutLayout(),
    this.infoRow = const InfoRowLayout(),
  });

  bool get go => runtimeType == GoLayout;

  bool get medium => runtimeType == MediumLayout;

  bool get large => runtimeType == LargeLayout;
}
