part of 'layout.dart';

class MediumLayout extends Layout {
  const MediumLayout({
    TemplatesLayout? templates,
    AppBarLayout? appBar,
    ActionButtonLayout? actionButton,
    ClockLayout? clockLayout,
    PhotoCalendarLayoutMedium? photoCalendarLayout,
    TimepillarLayout? timepillar,
    CategoryLayout? category,
    MenuPageLayout? menuPage,
    MonthCalendarLayout? monthCalendar,
    FontSize? fontSize,
    ActivityPageLayout? activityPage,
    ChecklistLayout? checklist,
    TimerPageLayout? timerPage,
    BorderLayout? borders,
    EventCardLayout? eventCard,
    AlarmPageLayout? alarmPage,
    AboutLayout? about,
    WeekCalendarLayout? weekCalendar,
  }) : super(
          templates: templates ?? const TemplatesLayoutMedium(),
          radius: 18,
          appBar: appBar ?? const AppBarLayoutMedium(),
          actionButton: actionButton ?? const ActionButtonLayoutMedium(),
          photoCalendarLayout:
              photoCalendarLayout ?? const PhotoCalendarLayoutMedium(),
          menuPage: menuPage ?? const MenuPageLayoutMedium(),
          myPhotos: const MyPhotosLayoutMedium(),
          toolbar: const ToolbarLayoutMedium(),
          navigationBar: const NavigationBarLayoutMedium(),
          tabBar: const TabBarLayoutMedium(),
          fontSize: fontSize ?? const FontSizeMedium(),
          icon: const IconLayoutMedium(),
          clock: clockLayout ?? const ClockLayoutMedium(),
          alarmPage: alarmPage ?? const AlarmPageLayoutMedium(),
          formPadding: const FormPaddingLayoutMedium(),
          weekCalendar: weekCalendar ?? const WeekCalendarLayoutMedium(),
          monthCalendar: monthCalendar ?? const MonthCalendarLayoutMedium(),
          eventCard: eventCard ?? const EventCardLayoutMedium(),
          timerPage: timerPage ?? const TimerPageLayoutMedium(),
          timepillar: timepillar ?? const TimepillarLayoutMedium(),
          settingsBasePage: const SettingsBasePageLayoutMedium(),
          defaultTextInputPage: const DefaultTextInputPageLayout(
            textFieldActionButtonSpacing: 18,
          ),
          imageArchive: const ImageArchiveLayoutMedium(),
          libraryPage: const LibraryPageLayoutMedium(),
          ongoingFullscreen: const OngoingTabLayout(
            height: 96,
            padding: EdgeInsets.symmetric(horizontal: 9),
            activity: OngoingActivityLayout(
              arrowSize: Size(48, 24),
              arrowPointRadius: Radius.circular(6),
              activeBorder: 4,
              border: 2,
              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 12),
              selectedPadding: EdgeInsets.symmetric(vertical: 3),
              dot: OngoingCategoryDotLayout(
                innerRadius: 6,
                outerRadius: 7,
                offset: 7,
                selectedOffset: 7,
              ),
            ),
          ),
          dataItem: const DataItemLayout(
            borderRadius: 20,
            picture: DataItemPictureLayout(
              stickerIconSize: 24,
              stickerSize: Size(48, 48),
              imagePadding: EdgeInsets.only(left: 11, right: 11, bottom: 7),
              titlePadding:
                  EdgeInsets.only(left: 7, right: 7, bottom: 4, top: 7),
            ),
          ),
          listDataItem: const ListDataItemLayout(
            folderPadding: EdgeInsets.only(left: 12, right: 8),
            imagePadding: EdgeInsets.only(left: 8, right: 12),
            textAndSubtitlePadding: EdgeInsets.only(top: 6, bottom: 12),
            iconSize: 48,
            secondaryTextHeight: 24 / 20,
          ),
          activityPage: activityPage ?? const ActivityPageLayoutMedium(),
          checklist: checklist ??
              const ChecklistLayout(
                question: ChecklistQuestionLayoutMedium(),
                listPadding: EdgeInsets.all(24),
                addNewQButtonPadding: EdgeInsets.fromLTRB(18, 12, 18, 18),
                addNewQIconPadding: EdgeInsets.only(left: 22, right: 16),
              ),
          note: const NoteLayout(
            notePadding: EdgeInsets.fromLTRB(27, 15, 24, 36),
            lineOffset: 3,
          ),
          iconTextButton: const IconTextButtonStyle(
            minimumSize: Size(376, 96),
            maximumSize: Size(double.infinity, 96),
          ),
          nextButton: const IconTextButtonStyle(
            minimumSize: Size(346, 96),
            maximumSize: Size(346, 96),
          ),
          alarmSettingsPage: const AlarmSettingsPageLayoutMedium(),
          components: const ComponentsLayout(
            subHeadingPadding: EdgeInsets.only(bottom: 12),
          ),
          pickField: const PickFieldLayout(
            padding: EdgeInsets.only(left: 18, right: 18),
            imagePadding: EdgeInsets.only(left: 0, right: 12),
            leadingPadding: EdgeInsets.only(right: 18),
            height: 88,
            leadingSize: Size(72, 72),
          ),
          eventImageLayout: const EventImageLayout(
            fallbackCrossPadding: EdgeInsets.all(6),
            fallbackCheckPadding: EdgeInsets.all(12),
          ),
          listFolder: const ListFolderLayout(
            iconSize: 68,
            imageBorderRadius: 4,
            imagePadding: EdgeInsets.fromLTRB(8, 25, 8, 15),
            margin: EdgeInsets.only(left: 4, right: 8),
          ),
          borders: borders ?? const BorderLayoutMedium(),
          linedBorder: const LinedBorderLayout(dashSize: 6),
          selectableField: const SelectableFieldLayout(
            height: 72,
            position: -9,
            size: 36,
            textLeftPadding: 18,
            textRightPadding: 39,
            textTopPadding: 15,
            padding: EdgeInsets.all(6),
          ),
          category: category ?? const CategoryLayoutMedium(),
          radio: const RadioLayout(
            outerRadius: 17.25,
            innerRadius: 12.75,
          ),
          selectPicture: const SelectPictureLayout(
            imageSize: 126,
            imageSizeLarge: 178,
            padding: 6,
            paddingLarge: 8.48,
            removeButtonPadding: EdgeInsets.fromLTRB(9, 12, 9, 12),
          ),
          timeInput: const TimeInputLayoutMedium(),
          recording: const RecordingLayoutMedium(),
          arrows: const ArrowsLayout(
            collapseMargin: 3,
            radius: 150,
            size: 72,
          ),
          menuButton: const MenuButtonLayout(
            dotPosition: -4.5,
          ),
          commonCalendar: const CommonCalendarLayout(
            fullDayStackDistance: 6,
            goToNowButtonTop: 48,
            fullDayPadding: EdgeInsets.all(18),
            fullDayButtonPadding: EdgeInsets.fromLTRB(15, 6, 6, 6),
          ),
          message: const MessageLayoutMedium(),
          slider: const SliderLayout(
            defaultHeight: 84,
            leftPadding: 18,
            rightPadding: 6,
            iconRightPadding: 18,
            thumbRadius: 18,
            elevation: 1.5,
            pressedElevation: 3,
            outerBorder: 3,
            trackHeight: 6,
          ),
          switchField: const SwitchFieldLayout(
            height: 84,
            toggleSize: 72,
            padding: EdgeInsets.only(left: 18.0, right: 6.0),
          ),
          login: const LoginLayout(
            topFormDistance: 48,
            logoSize: 96,
            logoHeight: 96,
            createAccountPadding: EdgeInsets.fromLTRB(16, 8, 16, 32),
            loginButtonPadding: EdgeInsets.fromLTRB(24, 48, 24, 0),
            termsPadding: 72,
          ),
          dialog: const DialogLayout(
            iconTextDistance: 36,
            fullscreenTop: 192,
            fullscreenIconDistance: 120,
          ),
          activityPreview: const ActivityAlarmPreviewLayout(
            radius: 6,
            height: 384,
            activityHeight: 1200,
            activityWidth: 675,
          ),
          logout: const LogoutLayoutMedium(),
          settings: const SettingsLayoutMedium(),
          permissionsPage: const PermissionsPageLayout(
            deniedDotPosition: -15,
            deniedContainerSize: 48,
            deniedBorderRadius: 24,
            deniedPadding: EdgeInsets.only(top: 6),
            deniedVerticalPadding: EdgeInsets.symmetric(vertical: 6),
          ),
          editTimer: const EditTimerPageLayout(
            inputTimeWidth: 180,
            inputTimePadding: 24,
            wheelPadding: EdgeInsets.only(top: 32),
          ),
          button: const ButtonLayoutMedium(),
          theme: const ThemeLayout(
            circleRadius: 36,
            inputPadding: EdgeInsets.symmetric(vertical: 21, horizontal: 24),
          ),
          dot: const DotLayout(
            bigDotSize: 42,
            miniDotSize: 6,
            bigDotPadding: 9,
          ),
          fab: const FloatingActionButtonLayout(padding: EdgeInsets.all(24)),
          crossOver: const CrossOverLayoutMedium(),
          selector: const SelectorLayoutMedium(),
          startupPage: const StartupPageLayoutMedium(),
          starterSetDialog: const StarterSetDialogLayoutMedium(),
          termsOfUseDialog: const TermsOfUseDialogLayoutMedium(),
          progressIndicator: const ProgressIndicatorLayoutMedium(),
          supportPerson: const SupportPersonLayoutMedium(),
          about: const AboutLayoutMedium(),
          infoRow: const InfoRowLayoutMedium(),
        );
}
