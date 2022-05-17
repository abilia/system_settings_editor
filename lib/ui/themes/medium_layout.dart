part of 'layout.dart';

class MediumLayout extends Layout {
  const MediumLayout()
      : super(
          radius: 18,
          appBar: const AppBarLayout(
            largeAppBarHeight: 148,
            height: 104,
            fontSize: 32,
            horizontalPadding: 16,
            previewWidth: 562.5,
          ),
          actionButton: const ActionButtonLayout(
            size: 88,
            radius: 20,
            spacing: 4,
            padding: EdgeInsets.all(12),
            withTextPadding: EdgeInsets.only(left: 6, top: 6, right: 6),
          ),
          menuPage: const MenuPageLayout(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 46),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            crossAxisCount: 3,
            menuItemButton: MenuItemButtonLayout(
              size: 96,
              borderRadius: 20,
              orangeDotInset: 6,
              orangeDotRadius: 9,
            ),
          ),
          myPhotos: const MyPhotosLayout(
            crossAxisCount: 3,
            fullScreenImageBorderRadius: 20,
            childAspectRatio: 240 / 168,
            fullScreenImagePadding: EdgeInsets.fromLTRB(24, 22, 24, 24),
          ),
          toolbar: const ToolbarLayout(
            height: 120,
          ),
          navigationBar: const NavigationBarLayout(
            height: 128,
            spaceBetweeen: 12,
            padding: EdgeInsets.only(left: 18, top: 12, right: 18, bottom: 20),
          ),
          tabBar: const TabBarLayout(
            item: TabItemLayout(
              width: 118,
              border: 2,
            ),
            height: 104,
            bottomPadding: 8,
          ),
          fontSize: const FontSize(
            headline1: 144,
            headline2: 90,
            headline3: 72,
            headline4: 45,
            headline5: 38,
            headline6: 32,
            subtitle1: 24,
            subtitle2: 21,
            bodyText1: 24,
            bodyText2: 21,
            caption: 20,
            button: 24,
            overline: 15,
          ),
          icon: const IconLayout(
            tiny: 30,
            small: 36,
            button: 42,
            normal: 64,
            large: 96,
            huge: 192,
            doubleIconTop: 30,
            doubleIconLeft: 48,
          ),
          clock: const ClockLayout(
            height: 124,
            width: 92,
            borderWidth: 2,
            centerPointRadius: 8,
            hourNumberScale: 1.5,
            hourHandLength: 22,
            minuteHandLength: 30,
            hourHandWidth: 1.5,
            minuteHandWidth: 1.5,
            fontSize: 12,
          ),
          formPadding: const FormPaddingLayout(
            verticalItemDistance: 12,
            largeVerticalItemDistance: 18,
            groupBottomDistance: 24,
            groupTopDistance: 36,
            horizontalItemDistance: 12,
            largeHorizontalItemDistance: 18,
            groupHorizontalDistance: 24,
            largeGroupDistance: 48,
            selectorDistance: 3,
          ),
          weekCalendar: const WeekCalendarLayout(
            activityBorderWidth: 2.25,
            currentActivityBorderWidth: 4.5,
            dayDistance: 3,
            headerTopPadding: 6,
            headerTopPaddingSmall: 4.5,
            headerBottomPadding: 6,
            headerHeight: 66,
            fullDayHeight: 54,
            activityDistance: 3,
            crossOverPadding: EdgeInsets.fromLTRB(6, 6, 6, 18),
            bodyPadding: EdgeInsets.fromLTRB(3, 6, 3, 6),
            activityTextPadding: EdgeInsets.all(4.5),
            innerDayPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 3),
          ),
          monthCalendar: const MonthCalendarLayout(
            monthContentFlex: 620,
            monthListPreviewFlex: 344,
            monthHeadingHeight: 48,
            dayRadius: 12,
            dayRadiusHighlighted: 14,
            dayBorderWidth: 2,
            dayBorderWidthHighlighted: 6,
            dayHeaderHeight: 28,
            dayHeadingFontSize: 20,
            weekNumberWidth: 36,
            hasActivitiesDotRadius: 5,
            dayViewMargin: EdgeInsets.all(4),
            dayViewMarginHighlighted: EdgeInsets.all(1),
            dayViewPadding: EdgeInsets.all(0),
            dayViewPaddingHighlighted: EdgeInsets.all(3),
            dayHeaderPadding: EdgeInsets.only(left: 6, right: 6, top: 6),
            dayContainerPadding:
                EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 6),
            hasActivitiesDotPadding: EdgeInsets.only(top: 2),
            activityTextContentPadding: EdgeInsets.all(4),
            monthPreview: MonthPreviewLayout(
              monthPreviewBorderWidth: 2,
              activityListTopPadding: 32,
              activityListBottomPadding: 96,
              headingHeight: 72,
              headingFullDayActivityHeight: 54,
              headingFullDayActivityWidth: 57,
              headingButtonIconSize: 36,
              monthListPreviewPadding:
                  EdgeInsets.only(left: 12, top: 32, right: 12),
              headingPadding: EdgeInsets.only(left: 18, right: 16),
              noSelectedDayPadding: EdgeInsets.only(top: 64),
              crossOverPadding: EdgeInsets.all(6),
              dateTextCrossOverSize: Size(336, 56),
            ),
          ),
          eventCard: const EventCardLayout(
            height: 104,
            marginSmall: 8,
            marginLarge: 16,
            imageSize: 88,
            categorySideOffset: 76,
            iconSize: 24.0,
            titleImagePadding: 12,
            borderWidth: 4,
            currentBorderWidth: 6,
            imagePadding: EdgeInsets.only(left: 8),
            crossPadding: EdgeInsets.all(8),
            titlePadding:
                EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 16),
            statusesPadding: EdgeInsets.only(right: 12, bottom: 8),
            privateIconSize: 36,
            cardIconPadding: EdgeInsets.only(right: 6),
          ),
          timerPage: const TimerPageLayout(
            topInfoHeight: 232,
            imageSize: 200,
            imagePadding: 16,
            topPadding: EdgeInsets.all(16),
          ),
          timePillar: const TimepillarLayout(
            fontSize: 40,
            width: 80,
            padding: 8,
            hourPadding: 1.5,
            flarpRadius: 12,
            dot: TimepillarDotLayout(
              size: 16,
              padding: 4,
            ),
            card: TimepillarCardLayout(
              width: 120,
              activityMinHeight: 140,
              imageMinHeight: 96,
              padding: EdgeInsets.all(8),
              distance: 8,
            ),
            twoTimePillar: TwoTimepillarLayout(
              verticalMargin: 36,
              nightMargin: 6,
              radius: 18,
            ),
          ),
          settingsBasePage: const SettingsBasePageLayout(
            itemPadding: EdgeInsets.fromLTRB(18, 12, 24, 0),
            listPadding: EdgeInsets.symmetric(vertical: 16),
            dividerThemeData: DividerThemeData(
              space: 48,
              thickness: 2,
              endIndent: 18,
            ),
          ),
          defaultTextInputPage: const DefaultTextInputPageLayout(
            textFieldActionButtonSpacing: 18,
          ),
          imageArchive: const ImageArchiveLayout(
            imageWidth: 140,
            imageHeight: 129,
            imagePadding: 3,
            imageNameBottomPadding: 3,
            fullscreenImagePadding: 18,
            aspectRatio: 188 / 180,
          ),
          libraryPage: const LibraryPageLayout(
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            crossAxisCount: 4,
            headerPadding: EdgeInsets.fromLTRB(24, 12, 0, 3),
            folderImagePadding: EdgeInsets.fromLTRB(15, 42, 15, 24),
            notePadding: EdgeInsets.fromLTRB(7.5, 13.5, 7.5, 9),
            contentPadding: EdgeInsets.all(6),
            folderIconSize: 128,
            headerFontSize: 32,
            childAspectRatio: 183 / 188,
            imageHeight: 144,
            imageWidth: 140,
            textImageDistance: 3,
            emptyMessageTopPadding: 90,
            folderImageRadius: 6,
          ),
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
            picture: _DataItemPictureLayout(
              stickerIconSize: 24,
              stickerSize: Size(48, 48),
              imagePadding: EdgeInsets.only(left: 11, right: 11, bottom: 7),
              titlePadding:
                  EdgeInsets.only(left: 7, right: 7, bottom: 4, top: 7),
            ),
          ),
          activityPage: const ActivityPageLayout(
            topInfoHeight: 232,
            timeRowPadding: EdgeInsets.only(bottom: 16),
            topInfoPadding: EdgeInsets.all(16),
            titleImageHorizontalSpacing: 16,
            imagePadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            verticalInfoPaddingCheckable: EdgeInsets.only(top: 24, bottom: 16),
            verticalInfoPaddingNonCheckable:
                EdgeInsets.only(top: 24, bottom: 14),
            horizontalInfoPadding: EdgeInsets.symmetric(horizontal: 16),
            checkButtonPadding: EdgeInsets.only(bottom: 22),
            checklistPadding: EdgeInsets.fromLTRB(27, 15, 28, 0),
            titleFontSize: 48,
            titleLineHeight: 56.25,
            checkButtonHeight: 72,
            checkButtonContentPadding:
                EdgeInsets.fromLTRB(14.25, 15, 31.75, 15),
            dividerHeight: 2,
            dividerIndentation: 16,
            dashWidth: 12,
            dashSpacing: 12,
            timeCrossOverSize: Size(112, 56),
            minTimeBoxWidth: 108,
            timeBoxSize: Size(144, 80),
            timeBoxPadding: EdgeInsets.all(16),
            timeBoxCurrentBorderWidth: 3,
            timeBoxFutureBorderWidth: 2,
          ),
          checklist: const ChecklistLayout(
            question: ChecklistQuestionLayout(
              imagePadding: EdgeInsets.fromLTRB(10, 10, 0, 10),
              titlePadding: EdgeInsets.fromLTRB(12, 16, 0, 16),
              iconPadding: EdgeInsets.fromLTRB(16, 22, 22, 22),
              viewHeight: 80,
              imageSize: 60,
              fontSize: 28,
              lineHeight: 48,
            ),
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
          alarmPage: const AlarmPageLayout(
            alarmClockPadding: EdgeInsets.only(top: 6, bottom: 4, right: 24),
          ),
          alarmSettingsPage: const AlarmSettingsPageLayout(
            playButtonSeparation: 16,
            defaultPadding: EdgeInsets.fromLTRB(24, 16, 32, 0),
            topPadding: EdgeInsets.fromLTRB(24, 36, 32, 0),
            bottomPadding: EdgeInsets.fromLTRB(24, 24, 32, 96),
            dividerPadding: EdgeInsets.only(top: 24, bottom: 16),
          ),
          components: const ComponentsLayout(
            subHeadingPadding: EdgeInsets.only(bottom: 12),
          ),
          pickField: const PickFieldLayout(
            padding: EdgeInsets.only(left: 18, right: 18),
            imagePadding: EdgeInsets.only(left: 4, right: 12),
            leadingPadding: EdgeInsets.only(right: 18),
            height: 88,
            leadingSize: Size(72, 72),
            verticalDistanceText: 6,
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
          templates: const LayoutTemplates(
            s1: EdgeInsets.all(18),
            s3: EdgeInsets.all(6),
            bottomNavigation: EdgeInsets.fromLTRB(18, 12, 18, 18),
            m1: EdgeInsets.fromLTRB(24, 36, 24, 64),
            m2: EdgeInsets.fromLTRB(0, 32, 0, 32),
            m3: EdgeInsets.fromLTRB(24, 36, 24, 24),
            m4: EdgeInsets.symmetric(horizontal: 32),
            m5: EdgeInsets.fromLTRB(24, 96, 24, 24),
            l2: EdgeInsets.symmetric(horizontal: 32, vertical: 96),
            l4: EdgeInsets.symmetric(vertical: 96),
          ),
          borders: const BorderLayout(thin: 1.5, medium: 3),
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
          category: const CategoryLayout(
            height: 66,
            radius: 150,
            startPadding: 12,
            endPadding: 6,
            emptySize: 24,
            topMargin: 6,
            imageDiameter: 54,
            noColorsImageSize: 45,
            radioPadding: EdgeInsets.all(12),
            imagePadding: EdgeInsets.all(4.5),
          ),
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
          timeInput: const TimeInputLayout(
            height: 96,
            width: 180,
            amPmHeight: 72,
            amPmWidth: 88.5,
            timeDashAlignValue: 21,
            amPmDistance: 3,
            headerClockPadding: EdgeInsets.only(right: 18),
            inputKeyboardDistance: 96,
            keyboardButtonHeight: 88,
            keyboardButtonWidth: 160,
            keyboardButtonPadding: 12,
          ),
          recording: const RecordingLayout(
            trackHeight: 6,
            thumbRadius: 18,
            padding: EdgeInsets.symmetric(horizontal: 48),
          ),
          arrows: const ArrowsLayout(
            collapseMargin: 3,
            radius: 150,
            size: 72,
          ),
          menuButton: const MenuButtonLayout(
            dotPosition: -4.5,
          ),
          agenda: const AgendaLayout(
            topPadding: 90,
            bottomPadding: 187.5,
            sliverTopPadding: 144,
          ),
          commonCalendar: const CommonCalendarLayout(
            fullDayStackDistance: 6,
            goToNowButtonTop: 48,
            fullDayPadding: EdgeInsets.all(18),
            fullDayButtonPadding: EdgeInsets.fromLTRB(15, 6, 6, 6),
          ),
          message: const MessageLayout(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
          ),
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
            progressWidth: 9,
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
          logout: const LogoutLayout(
            profilePictureSize: 126,
            profileDistance: 35,
          ),
          photoCalendar: const PhotoCalendarLayout(
            clockSize: 200,
            clockFontSize: 72,
            clockFontSizeSmall: 64,
            backButtonPosition: 18,
            clockPadding: EdgeInsets.all(30),
            digitalClockPadding: EdgeInsets.symmetric(vertical: 30),
          ),
          settings: const SettingsLayout(
            clockHeight: 135,
            clockWidth: 108,
            previewTimePillarWidth: 207,
            intervalStepperWidth: 345,
            monthPreviewHeight: 144,
            monthPreviewHeaderHeight: 48,
            weekCalendarHeight: 222,
            weekCalendarHeadingHeight: 66,
            weekDayHeight: 129,
            permissionsDotPosition: 12,
            monthDaysPadding: EdgeInsets.only(left: 6, right: 6),
            weekDaysPadding: EdgeInsets.symmetric(horizontal: 3),
            textToSpeechPadding: EdgeInsets.only(left: 12, right: 6),
          ),
          permissionsPage: const PermissionsPageLayout(
            deniedDotPosition: -15,
            deniedContainerSize: 48,
            deniedBorderRadius: 24,
            deniedPadding: EdgeInsets.only(top: 6),
            deniedVerticalPadding: EdgeInsets.symmetric(vertical: 6),
          ),
          editTimer: const EditTimerLayout(
            inputTimeWidth: 180,
            wheelPadding: EdgeInsets.only(top: 32),
          ),
          button: const ButtonLayout(
              baseButtonMinHeight: 96,
              redButtonMinSize: Size(0, 72),
              secondaryActionButtonMinSize: 60,
              textButtonInsets:
                  EdgeInsets.symmetric(horizontal: 48, vertical: 30),
              actionButtonIconTextPadding: EdgeInsets.fromLTRB(15, 15, 30, 15),
              startBasicTimerPadding: EdgeInsets.fromLTRB(0, 8, 8, 8)),
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
          crossOver: const CrossOverLayout(strokeWidth: 3),
        );
}
