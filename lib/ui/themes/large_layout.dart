part of 'layout.dart';

class _LargeLayout extends Layout {
  static const double scaleFactor = 1;
  const _LargeLayout()
      : super(
          radius: 18 * scaleFactor,
          appBar: const AppBarLayout(
            largeAppBarHeight: 148 * scaleFactor,
            height: 104 * scaleFactor,
            fontSize: 32 * scaleFactor,
            horizontalPadding: 16 * scaleFactor,
            previewWidth: 562.5 * scaleFactor,
          ),
          actionButton: const ActionButtonLayout(
            size: 88 * scaleFactor,
            radius: 20 * scaleFactor,
            spacing: 4 * scaleFactor,
            padding: EdgeInsets.all(12 * scaleFactor),
            withTextPadding: EdgeInsets.only(
                left: 6 * scaleFactor,
                top: 6 * scaleFactor,
                right: 6 * scaleFactor),
          ),
          menuPage: const MenuPageLayout(
            padding: EdgeInsets.symmetric(
                vertical: 32 * scaleFactor, horizontal: 46 * scaleFactor),
            crossAxisSpacing: 24 * scaleFactor,
            mainAxisSpacing: 24 * scaleFactor,
            crossAxisCount: 3,
            menuItemButton: MenuItemButtonLayout(
              size: 96 * scaleFactor,
              borderRadius: 20 * scaleFactor,
              orangeDotInset: 6 * scaleFactor,
              orangeDotRadius: 9 * scaleFactor,
            ),
          ),
          myPhotos: const MyPhotosLayout(
            crossAxisCount: 3,
            fullScreenImageBorderRadius: 20 * scaleFactor,
            childAspectRatio: 240 / 188,
            fullScreenImagePadding: EdgeInsets.fromLTRB(24 * scaleFactor,
                22 * scaleFactor, 24 * scaleFactor, 24 * scaleFactor),
            addPhotoButtonPadding: EdgeInsets.only(
                top: 8 * scaleFactor,
                bottom: 8 * scaleFactor,
                right: 16 * scaleFactor),
          ),
          toolbar: const ToolbarLayout(
            height: 120 * scaleFactor,
          ),
          navigationBar: const NavigationBarLayout(
            height: 128 * scaleFactor,
            spaceBetweeen: 12 * scaleFactor,
            padding: EdgeInsets.only(
                left: 18 * scaleFactor,
                top: 12 * scaleFactor,
                right: 18 * scaleFactor,
                bottom: 20 * scaleFactor),
          ),
          tabBar: const TabBarLayout(
            item: TabItemLayout(
              width: 118 * scaleFactor,
              border: 2 * scaleFactor,
            ),
            height: 104 * scaleFactor,
            bottomPadding: 8 * scaleFactor,
          ),
          fontSize: const FontSize(
            headline1: 144 * scaleFactor,
            headline2: 90 * scaleFactor,
            headline3: 72 * scaleFactor,
            headline4: 45 * scaleFactor,
            headline5: 38 * scaleFactor,
            headline6: 32 * scaleFactor,
            subtitle1: 24 * scaleFactor,
            subtitle2: 21 * scaleFactor,
            bodyText1: 24 * scaleFactor,
            bodyText2: 21 * scaleFactor,
            caption: 20 * scaleFactor,
            button: 24 * scaleFactor,
            overline: 15 * scaleFactor,
          ),
          icon: const IconLayout(
            tiny: 30 * scaleFactor,
            small: 36 * scaleFactor,
            button: 42 * scaleFactor,
            normal: 64 * scaleFactor,
            large: 96 * scaleFactor,
            huge: 192 * scaleFactor,
            doubleIconTop: 30 * scaleFactor,
            doubleIconLeft: 48 * scaleFactor,
          ),
          clock: const ClockLayout(
            height: 124 * scaleFactor,
            width: 92 * scaleFactor,
            borderWidth: 2 * scaleFactor,
            centerPointRadius: 8 * scaleFactor,
            hourNumberScale: 1.5 * scaleFactor,
            hourHandLength: 22 * scaleFactor,
            minuteHandLength: 30 * scaleFactor,
            hourHandWidth: 1.5 * scaleFactor,
            minuteHandWidth: 1.5 * scaleFactor,
            fontSize: 12 * scaleFactor,
          ),
          formPadding: const FormPaddingLayout(
            verticalItemDistance: 12 * scaleFactor,
            largeVerticalItemDistance: 18 * scaleFactor,
            groupBottomDistance: 24 * scaleFactor,
            groupTopDistance: 36 * scaleFactor,
            horizontalItemDistance: 12 * scaleFactor,
            largeHorizontalItemDistance: 18 * scaleFactor,
            groupHorizontalDistance: 24 * scaleFactor,
            largeGroupDistance: 48 * scaleFactor,
            selectorDistance: 3 * scaleFactor,
          ),
          weekCalendar: const WeekCalendarLayout(
            activityBorderWidth: 2.25 * scaleFactor,
            currentActivityBorderWidth: 4.5 * scaleFactor,
            dayDistance: 3 * scaleFactor,
            headerTopPadding: 6 * scaleFactor,
            headerTopPaddingSmall: 4.5 * scaleFactor,
            headerBottomPadding: 6 * scaleFactor,
            headerHeight: 66 * scaleFactor,
            fullDayHeight: 54 * scaleFactor,
            activityDistance: 3 * scaleFactor,
            crossOverPadding: EdgeInsets.fromLTRB(6 * scaleFactor,
                6 * scaleFactor, 6 * scaleFactor, 18 * scaleFactor),
            bodyPadding: EdgeInsets.fromLTRB(3 * scaleFactor, 6 * scaleFactor,
                3 * scaleFactor, 6 * scaleFactor),
            activityTextPadding: EdgeInsets.all(4.5 * scaleFactor),
            innerDayPadding: EdgeInsets.symmetric(
                vertical: 9 * scaleFactor, horizontal: 3 * scaleFactor),
          ),
          monthCalendar: const MonthCalendarLayout(
              monthContentFlex: 620,
              monthListPreviewFlex: 344,
              monthHeadingHeight: 48 * scaleFactor,
              dayRadius: 12 * scaleFactor,
              dayRadiusHighlighted: 14 * scaleFactor,
              dayBorderWidth: 2 * scaleFactor,
              dayBorderWidthHighlighted: 6 * scaleFactor,
              dayHeaderHeight: 28 * scaleFactor,
              dayHeadingFontSize: 20 * scaleFactor,
              weekNumberWidth: 36 * scaleFactor,
              hasActivitiesDotRadius: 5 * scaleFactor,
              dayViewMargin: EdgeInsets.all(4 * scaleFactor),
              dayViewMarginHighlighted: EdgeInsets.all(1 * scaleFactor),
              dayViewPadding: EdgeInsets.all(0 * scaleFactor),
              dayViewPaddingHighlighted: EdgeInsets.all(3 * scaleFactor),
              dayHeaderPadding: EdgeInsets.only(
                  left: 6 * scaleFactor,
                  right: 6 * scaleFactor,
                  top: 6 * scaleFactor),
              dayContainerPadding: EdgeInsets.only(
                  left: 6 * scaleFactor,
                  right: 6 * scaleFactor,
                  top: 4 * scaleFactor,
                  bottom: 6 * scaleFactor),
              hasActivitiesDotPadding: EdgeInsets.only(top: 2 * scaleFactor),
              activityTextContentPadding: EdgeInsets.all(4 * scaleFactor),
              monthPreview: MonthPreviewLayout(
                monthPreviewBorderWidth: 2 * scaleFactor,
                activityListTopPadding: 32 * scaleFactor,
                activityListBottomPadding: 96 * scaleFactor,
                headingHeight: 72 * scaleFactor,
                headingFullDayActivityHeight: 54 * scaleFactor,
                headingFullDayActivityWidth: 57 * scaleFactor,
                headingButtonIconSize: 36 * scaleFactor,
                monthListPreviewPadding: EdgeInsets.only(
                    left: 12 * scaleFactor,
                    top: 32 * scaleFactor,
                    right: 12 * scaleFactor),
                headingPadding: EdgeInsets.only(
                    left: 18 * scaleFactor, right: 16 * scaleFactor),
                noSelectedDayPadding: EdgeInsets.only(top: 64 * scaleFactor),
              )),
          eventCard: const EventCardLayout(
            height: 104 * scaleFactor,
            marginSmall: 8 * scaleFactor,
            marginLarge: 16 * scaleFactor,
            imageSize: 88 * scaleFactor,
            categorySideOffset: 76 * scaleFactor,
            iconSize: 24.0 * scaleFactor,
            titleImagePadding: 12 * scaleFactor,
            crossOverStrokeWidth: 2 * scaleFactor,
            borderWidth: 4 * scaleFactor,
            currentBorderWidth: 6 * scaleFactor,
            imagePadding: EdgeInsets.only(left: 8 * scaleFactor),
            crossPadding: EdgeInsets.all(8 * scaleFactor),
            titlePadding: EdgeInsets.only(
                left: 12 * scaleFactor,
                top: 12 * scaleFactor,
                right: 12 * scaleFactor,
                bottom: 16 * scaleFactor),
            statusesPadding: EdgeInsets.only(
                right: 12 * scaleFactor, bottom: 8 * scaleFactor),
            privateIconSize: 36 * scaleFactor,
            cardIconPadding: EdgeInsets.only(right: 6 * scaleFactor),
          ),
          timerPage: const TimerPageLayout(
            topInfoHeight: 232 * scaleFactor,
            imageSize: 200 * scaleFactor,
            imagePadding: 16 * scaleFactor,
            topPadding: EdgeInsets.all(16 * scaleFactor),
          ),
          timePillar: const TimepillarLayout(
            fontSize: 40 * scaleFactor,
            width: 80 * scaleFactor,
            padding: 8 * scaleFactor,
            hourPadding: 1.5 * scaleFactor,
            flarpRadius: 12 * scaleFactor,
            dot: TimepillarDotLayout(
              size: 16 * scaleFactor,
              padding: 4 * scaleFactor,
            ),
            card: TimepillarCardLayout(
              width: 120 * scaleFactor,
              activityMinHeight: 140 * scaleFactor,
              imageMinHeight: 96 * scaleFactor,
              padding: EdgeInsets.all(8 * scaleFactor),
              distance: 8 * scaleFactor,
            ),
            twoTimePillar: TwoTimepillarLayout(
              verticalMargin: 36 * scaleFactor,
              nightMargin: 6 * scaleFactor,
              radius: 18 * scaleFactor,
            ),
          ),
          settingsBasePage: const SettingsBasePageLayout(
            itemPadding: EdgeInsets.fromLTRB(18 * scaleFactor, 12 * scaleFactor,
                24 * scaleFactor, 0 * scaleFactor),
            listPadding: EdgeInsets.symmetric(vertical: 16 * scaleFactor),
            dividerThemeData: DividerThemeData(
              space: 48 * scaleFactor,
              thickness: 2 * scaleFactor,
              endIndent: 18 * scaleFactor,
            ),
          ),
          defaultTextInputPage: const DefaultTextInputPageLayout(
            textFieldActionButtonSpacing: 18 * scaleFactor,
          ),
          imageArchive: const ImageArchiveLayout(
            imageWidth: 140 * scaleFactor,
            imageHeight: 129 * scaleFactor,
            imagePadding: 3 * scaleFactor,
            imageNameBottomPadding: 3 * scaleFactor,
            fullscreenImagePadding: 18 * scaleFactor,
            aspectRatio: 188 / 180,
          ),
          libraryPage: const LibraryPageLayout(
            mainAxisSpacing: 12 * scaleFactor,
            crossAxisSpacing: 12 * scaleFactor,
            crossAxisCount: 4,
            headerPadding: EdgeInsets.fromLTRB(24 * scaleFactor,
                12 * scaleFactor, 0 * scaleFactor, 3 * scaleFactor),
            folderImagePadding: EdgeInsets.fromLTRB(15 * scaleFactor,
                42 * scaleFactor, 15 * scaleFactor, 24 * scaleFactor),
            notePadding: EdgeInsets.fromLTRB(
                7.5 * scaleFactor, 13.5 * scaleFactor, 7.5 * scaleFactor, 9),
            contentPadding: EdgeInsets.all(6 * scaleFactor),
            folderIconSize: 129 * scaleFactor,
            headerFontSize: 32 * scaleFactor,
            childAspectRatio: 183 / 215,
            imageHeight: 144 * scaleFactor,
            imageWidth: 140 * scaleFactor,
            textImageDistance: 3 * scaleFactor,
            emptyMessageTopPadding: 90 * scaleFactor,
            folderImageRadius: 6 * scaleFactor,
          ),
          ongoingFullscreen: const OngoingTabLayout(
            height: 96 * scaleFactor,
            padding: EdgeInsets.symmetric(horizontal: 9 * scaleFactor),
            activity: OngoingActivityLayout(
              arrowSize: Size(48 * scaleFactor, 24 * scaleFactor),
              arrowPointRadius: Radius.circular(6 * scaleFactor),
              activeBorder: 4 * scaleFactor,
              border: 2 * scaleFactor,
              padding: EdgeInsets.symmetric(
                  horizontal: 9 * scaleFactor, vertical: 12 * scaleFactor),
              selectedPadding: EdgeInsets.symmetric(vertical: 3 * scaleFactor),
              dot: OngoingCategoryDotLayout(
                innerRadius: 6 * scaleFactor,
                outerRadius: 7 * scaleFactor,
                offset: 7 * scaleFactor,
                selectedOffset: 7 * scaleFactor,
              ),
            ),
          ),
          dataItem: const DataItemLayout(
            borderRadius: 20 * scaleFactor,
            picture: _DataItemPictureLayout(
              stickerIconSize: 24 * scaleFactor,
              stickerSize: Size(48 * scaleFactor, 48 * scaleFactor),
              imagePadding: EdgeInsets.only(
                  left: 11 * scaleFactor,
                  right: 11 * scaleFactor,
                  bottom: 7 * scaleFactor),
              titlePadding: EdgeInsets.only(
                  left: 7 * scaleFactor,
                  right: 7 * scaleFactor,
                  bottom: 4 * scaleFactor,
                  top: 7 * scaleFactor),
            ),
          ),
          activityPage: const ActivityPageLayout(
            topInfoHeight: 232 * scaleFactor,
            timeRowPadding: EdgeInsets.only(bottom: 16 * scaleFactor),
            topInfoPadding: EdgeInsets.all(16 * scaleFactor),
            titleImageHorizontalSpacing: 16 * scaleFactor,
            imagePadding: EdgeInsets.fromLTRB(16 * scaleFactor, 0 * scaleFactor,
                16 * scaleFactor, 16 * scaleFactor),
            verticalInfoPaddingCheckable: EdgeInsets.only(
                top: 24 * scaleFactor, bottom: 16 * scaleFactor),
            verticalInfoPaddingNonCheckable: EdgeInsets.only(
                top: 24 * scaleFactor, bottom: 14 * scaleFactor),
            horizontalInfoPadding:
                EdgeInsets.symmetric(horizontal: 16 * scaleFactor),
            checkButtonPadding: EdgeInsets.only(bottom: 22 * scaleFactor),
            checklistPadding: EdgeInsets.fromLTRB(27 * scaleFactor,
                15 * scaleFactor, 28 * scaleFactor, 0 * scaleFactor),
            titleFontSize: 48 * scaleFactor,
            titleLineHeight: 56.25 * scaleFactor,
            checkButtonHeight: 72 * scaleFactor,
            checkButtonContentPadding: EdgeInsets.fromLTRB(14.25 * scaleFactor,
                15 * scaleFactor, 31.75 * scaleFactor, 15 * scaleFactor),
            dividerHeight: 2 * scaleFactor,
            dividerIndentation: 16 * scaleFactor,
            dashWidth: 12 * scaleFactor,
            dashSpacing: 12 * scaleFactor,
            timeCrossOverSize: Size(112 * scaleFactor, 56 * scaleFactor),
            minTimeBoxWidth: 108 * scaleFactor,
            timeBoxSize: Size(144 * scaleFactor, 80 * scaleFactor),
            timeBoxPadding: EdgeInsets.all(16 * scaleFactor),
            timeBoxCurrentBorderWidth: 3 * scaleFactor,
            timeBoxFutureBorderWidth: 2 * scaleFactor,
          ),
          checkList: const CheckListLayout(
            questionViewPadding: EdgeInsets.only(bottom: 12 * scaleFactor),
            questionIconPadding: EdgeInsets.only(right: 22 * scaleFactor),
            questionImagePadding: EdgeInsets.fromLTRB(10 * scaleFactor,
                10 * scaleFactor, 0 * scaleFactor, 10 * scaleFactor),
            questionTitlePadding: EdgeInsets.only(
                left: 12 * scaleFactor, right: 16 * scaleFactor),
            addNewQButtonPadding: EdgeInsets.fromLTRB(18 * scaleFactor,
                12 * scaleFactor, 18 * scaleFactor, 18 * scaleFactor),
            addNewQIconPadding: EdgeInsets.only(
                left: 22 * scaleFactor, right: 16 * scaleFactor),
            questionListPadding: EdgeInsets.fromLTRB(18 * scaleFactor,
                18 * scaleFactor, 18 * scaleFactor, 0 * scaleFactor),
            questionViewHeight: 80 * scaleFactor,
            questionImageSize: 60 * scaleFactor,
            dividerHeight: 2 * scaleFactor,
            dividerIndentation: 16 * scaleFactor,
            toolbarButtonSize: 60 * scaleFactor,
          ),
          note: const NoteLayout(
            notePadding: EdgeInsets.fromLTRB(27 * scaleFactor, 15 * scaleFactor,
                24 * scaleFactor, 36 * scaleFactor),
          ),
          iconTextButton: const IconTextButtonStyle(
            minimumSize: Size(376 * scaleFactor, 96 * scaleFactor),
            maximumSize: Size(double.infinity, 96 * scaleFactor),
          ),
          nextButton: const IconTextButtonStyle(
            minimumSize: Size(346 * scaleFactor, 96 * scaleFactor),
            maximumSize: Size(346 * scaleFactor, 96 * scaleFactor),
          ),
          alarmPage: const AlarmPageLayout(
            alarmClockPadding: EdgeInsets.only(
                top: 6 * scaleFactor,
                bottom: 4 * scaleFactor,
                right: 24 * scaleFactor),
          ),
          alarmSettingsPage: const AlarmSettingsPageLayout(
            playButtonSeparation: 16 * scaleFactor,
            defaultPadding: EdgeInsets.fromLTRB(24 * scaleFactor,
                16 * scaleFactor, 32 * scaleFactor, 0 * scaleFactor),
            topPadding: EdgeInsets.fromLTRB(24 * scaleFactor, 36 * scaleFactor,
                32 * scaleFactor, 0 * scaleFactor),
            bottomPadding: EdgeInsets.fromLTRB(24 * scaleFactor,
                24 * scaleFactor, 32 * scaleFactor, 96 * scaleFactor),
            dividerPadding: EdgeInsets.only(
                top: 24 * scaleFactor, bottom: 16 * scaleFactor),
          ),
          components: const ComponentsLayout(
            subHeadingPadding: EdgeInsets.only(bottom: 12 * scaleFactor),
          ),
          pickField: const PickFieldLayout(
            padding: EdgeInsets.only(
                left: 18 * scaleFactor, right: 18 * scaleFactor),
            imagePadding:
                EdgeInsets.only(left: 4 * scaleFactor, right: 12 * scaleFactor),
            leadingPadding: EdgeInsets.only(right: 18 * scaleFactor),
            height: 88 * scaleFactor,
            leadingSize: Size(72 * scaleFactor, 72 * scaleFactor),
          ),
          eventImageLayout: const EventImageLayout(
            fallbackCrossPadding: EdgeInsets.all(6 * scaleFactor),
            fallbackCheckPadding: EdgeInsets.all(12 * scaleFactor),
          ),
          listFolder: const ListFolderLayout(
            iconSize: 68 * scaleFactor,
            imageBorderRadius: 4 * scaleFactor,
            imagePadding: EdgeInsets.fromLTRB(8 * scaleFactor, 25 * scaleFactor,
                8 * scaleFactor, 15 * scaleFactor),
            margin:
                EdgeInsets.only(left: 4 * scaleFactor, right: 8 * scaleFactor),
          ),
          templates: const LayoutTemplates(
            s1: EdgeInsets.all(18 * scaleFactor),
            s3: EdgeInsets.all(6 * scaleFactor),
            bottomNavigation: EdgeInsets.fromLTRB(18 * scaleFactor,
                12 * scaleFactor, 18 * scaleFactor, 18 * scaleFactor),
            m1: EdgeInsets.fromLTRB(24 * scaleFactor, 36 * scaleFactor,
                24 * scaleFactor, 64 * scaleFactor),
            m2: EdgeInsets.fromLTRB(0 * scaleFactor, 32 * scaleFactor,
                0 * scaleFactor, 32 * scaleFactor),
            m3: EdgeInsets.fromLTRB(24 * scaleFactor, 36 * scaleFactor,
                24 * scaleFactor, 24 * scaleFactor),
            m4: EdgeInsets.symmetric(horizontal: 32 * scaleFactor),
            m5: EdgeInsets.fromLTRB(24 * scaleFactor, 96 * scaleFactor,
                24 * scaleFactor, 24 * scaleFactor),
            l2: EdgeInsets.symmetric(
                horizontal: 32 * scaleFactor, vertical: 96 * scaleFactor),
            l4: EdgeInsets.symmetric(vertical: 96 * scaleFactor),
          ),
          borders: const BorderLayout(
              thin: 1.5 * scaleFactor, medium: 3 * scaleFactor),
          linedBorder: const LinedBorderLayout(dashSize: 6 * scaleFactor),
          selectableField: const SelectableFieldLayout(
            height: 72 * scaleFactor,
            position: -9 * scaleFactor,
            size: 36 * scaleFactor,
            textLeftPadding: 18 * scaleFactor,
            textRightPadding: 39 * scaleFactor,
            textTopPadding: 15 * scaleFactor,
            padding: EdgeInsets.all(6 * scaleFactor),
          ),
          category: const CategoryLayout(
            height: 66 * scaleFactor,
            radius: 150 * scaleFactor,
            startPadding: 12 * scaleFactor,
            endPadding: 6 * scaleFactor,
            emptySize: 24 * scaleFactor,
            topMargin: 6 * scaleFactor,
            imageDiameter: 54 * scaleFactor,
            noColorsImageSize: 45 * scaleFactor,
            radioPadding: EdgeInsets.all(12 * scaleFactor),
            imagePadding: EdgeInsets.all(4.5 * scaleFactor),
          ),
          radio: const RadioLayout(
            outerRadius: 17.25 * scaleFactor,
            innerRadius: 12.75 * scaleFactor,
          ),
          selectPicture: const SelectPictureLayout(
            imageSize: 126 * scaleFactor,
            padding: 6 * scaleFactor,
            removeButtonPadding: EdgeInsets.fromLTRB(9 * scaleFactor,
                12 * scaleFactor, 9 * scaleFactor, 12 * scaleFactor),
          ),
          timeInput: const TimeInputLayout(
            height: 96 * scaleFactor,
            width: 180 * scaleFactor,
            amPmHeight: 72 * scaleFactor,
            amPmWidth: 88.5 * scaleFactor,
            timeDashAlignValue: 21 * scaleFactor,
            amPmDistance: 3 * scaleFactor,
          ),
          recording: const RecordingLayout(
            trackHeight: 6 * scaleFactor,
            thumbRadius: 18 * scaleFactor,
            padding: EdgeInsets.symmetric(horizontal: 48 * scaleFactor),
          ),
          arrows: const ArrowsLayout(
            collapseMargin: 3 * scaleFactor,
            radius: 150 * scaleFactor,
            size: 72 * scaleFactor,
          ),
          menuButton: const MenuButtonLayout(
            dotPosition: -4.5 * scaleFactor,
          ),
          agenda: const AgendaLayout(
            topPadding: 90 * scaleFactor,
            bottomPadding: 187.5 * scaleFactor,
            sliverTopPadding: 144 * scaleFactor,
          ),
          commonCalendar: const CommonCalendarLayout(
            fullDayStackDistance: 6 * scaleFactor,
            goToNowButtonTop: 48 * scaleFactor,
            crossOverStrokeWidth: 2 * scaleFactor,
            crossOverFallback: 215 * scaleFactor,
            fullDayPadding: EdgeInsets.all(18 * scaleFactor),
            fullDayButtonPadding: EdgeInsets.fromLTRB(15 * scaleFactor,
                6 * scaleFactor, 6 * scaleFactor, 6 * scaleFactor),
          ),
          message: const MessageLayout(
            padding: EdgeInsets.symmetric(
              horizontal: 24 * scaleFactor,
              vertical: 30 * scaleFactor,
            ),
          ),
          slider: const SliderLayout(
            defaultHeight: 84 * scaleFactor,
            leftPadding: 18 * scaleFactor,
            rightPadding: 6 * scaleFactor,
            iconRightPadding: 18 * scaleFactor,
            thumbRadius: 18 * scaleFactor,
            elevation: 1.5 * scaleFactor,
            pressedElevation: 3 * scaleFactor,
            outerBorder: 3 * scaleFactor,
            trackHeight: 6 * scaleFactor,
          ),
          switchField: const SwitchFieldLayout(
            height: 84 * scaleFactor,
            toggleSize: 72 * scaleFactor,
            padding: EdgeInsets.only(
                left: 18.0 * scaleFactor, right: 6.0 * scaleFactor),
          ),
          login: const LoginLayout(
            topFormDistance: 48 * scaleFactor,
            logoSize: 96 * scaleFactor,
            progressWidth: 9 * scaleFactor,
            createAccountPadding: EdgeInsets.fromLTRB(16 * scaleFactor,
                8 * scaleFactor, 16 * scaleFactor, 32 * scaleFactor),
            loginButtonPadding: EdgeInsets.fromLTRB(24 * scaleFactor,
                48 * scaleFactor, 24 * scaleFactor, 0 * scaleFactor),
            termsPadding: 72 * scaleFactor,
          ),
          dialog: const DialogLayout(
            iconTextDistance: 36 * scaleFactor,
            fullscreenTop: 192 * scaleFactor,
            fullscreenIconDistance: 120 * scaleFactor,
          ),
          activityPreview: const ActivityAlarmPreviewLayout(
            radius: 6 * scaleFactor,
            height: 384 * scaleFactor,
            activityHeight: 1200 * scaleFactor,
            activityWidth: 675 * scaleFactor,
          ),
          logout: const LogoutLayout(
            profilePictureSize: 126 * scaleFactor,
            profileDistance: 35 * scaleFactor,
          ),
          photoCalendar: const PhotoCalendarLayout(
            clockSize: 200 * scaleFactor,
            clockFontSize: 72 * scaleFactor,
            clockFontSizeSmall: 64 * scaleFactor,
            backButtonPosition: 18 * scaleFactor,
            clockPadding: EdgeInsets.all(30 * scaleFactor),
            digitalClockPadding:
                EdgeInsets.symmetric(vertical: 30 * scaleFactor),
          ),
          settings: const SettingsLayout(
            clockHeight: 135 * scaleFactor,
            clockWidth: 108 * scaleFactor,
            previewTimePillarWidth: 207 * scaleFactor,
            intervalStepperWidth: 345 * scaleFactor,
            monthPreviewHeight: 144 * scaleFactor,
            monthPreviewHeaderHeight: 48 * scaleFactor,
            weekCalendarHeight: 222 * scaleFactor,
            weekCalendarHeadingHeight: 66 * scaleFactor,
            weekDayHeight: 129 * scaleFactor,
            permissionsDotPosition: 12 * scaleFactor,
            monthDaysPadding:
                EdgeInsets.only(left: 6 * scaleFactor, right: 6 * scaleFactor),
            weekDaysPadding: EdgeInsets.symmetric(horizontal: 3 * scaleFactor),
            textToSpeechPadding:
                EdgeInsets.only(left: 12 * scaleFactor, right: 6 * scaleFactor),
          ),
          permissionsPage: const PermissionsPageLayout(
            deniedDotPosition: -15 * scaleFactor,
            deniedContainerSize: 48 * scaleFactor,
            deniedBorderRadius: 24 * scaleFactor,
            deniedPadding: EdgeInsets.only(top: 6 * scaleFactor),
            deniedVerticalPadding:
                EdgeInsets.symmetric(vertical: 6 * scaleFactor),
          ),
          editTimer: const EditTimerLayout(
            inputTimeWidth: 180 * scaleFactor,
            textToWheelDistance: 60 * scaleFactor,
            inputTimePadding: EdgeInsets.symmetric(vertical: 57 * scaleFactor),
          ),
          button: const ButtonLayout(
            baseButtonMinHeight: 96 * scaleFactor,
            redButtonMinSize: Size(0 * scaleFactor, 72 * scaleFactor),
            secondaryActionButtonMinSize: 60 * scaleFactor,
            textButtonInsets: EdgeInsets.symmetric(
                horizontal: 48 * scaleFactor, vertical: 30 * scaleFactor),
            redButtonPadding: EdgeInsets.fromLTRB(15 * scaleFactor,
                15 * scaleFactor, 30 * scaleFactor, 15 * scaleFactor),
          ),
          theme: const ThemeLayout(
            circleRadius: 36 * scaleFactor,
            inputPadding: EdgeInsets.symmetric(
                vertical: 24 * scaleFactor, horizontal: 24 * scaleFactor),
          ),
          dot: const DotLayout(
            bigDotSize: 42 * scaleFactor,
            miniDotSize: 6 * scaleFactor,
            bigDotPadding: 9 * scaleFactor,
          ),
          fab: const FloatingActionButtonLayout(
              padding: EdgeInsets.all(24 * scaleFactor)),
        );
}
