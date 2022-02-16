part of 'layout.dart';

class _MediumLayout extends Layout {
  const _MediumLayout()
      : super(
          appBar: const AppBarLayout(
            largeAppBarHeight: 148,
            height: 104,
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
            ),
          ),
          myPhotos: const MyPhotosLayout(
            crossAxisCount: 3,
            fullScreenImageBorderRadius: 20,
            childAspectRatio: 240 / 168,
            fullScreenImagePadding: EdgeInsets.fromLTRB(24, 22, 24, 24),
            addPhotoButtonPadding:
                EdgeInsets.only(top: 8, bottom: 8, right: 16),
          ),
          toolbar: const ToolbarLayout(
            height: 120,
            bottomPadding: 8,
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
          iconSize: const IconSize(
            small: 48,
            button: 56,
            normal: 64,
            large: 96,
            huge: 192,
          ),
          clock: const ClockLayout(
            height: 124,
            width: 92,
            borderWidth: 2,
            centerPointRadius: 8,
            hourNumberScale: 1.5,
            hourHandLength: 22,
            minuteHandLength: 30,
            fontSize: 12,
          ),
          formPadding: const FormPaddingLayout(
            left: 18,
            right: 24,
            top: 36,
            verticalItemDistance: 12,
          ),
          weekCalendar: const WeekCalendarLayout(
            activityBorderWidth: 2.25,
            currentActivityBorderWidth: 4.5,
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
              hasActivitiesDotDiameter: 10,
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
              )),
          eventCard: const EventCardLayout(
            height: 104,
            marginSmall: 8,
            marginLarge: 16,
            imageSize: 88,
            categorySideOffset: 76,
            iconSize: 24.0,
            titleImagePadding: 12,
            crossOverStrokeWidth: 2,
            borderWidth: 4,
            currentBorderWidth: 6,
            imagePadding: EdgeInsets.only(left: 8),
            crossPadding: EdgeInsets.all(8),
            titlePadding:
                EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 16),
            statusesPadding: EdgeInsets.only(right: 12, bottom: 8),
          ),
          timerPage: const TimerPageLayout(
            topInfoHeight: 232,
            imageSize: 200,
            imagePadding: 16,
            bodyPadding: EdgeInsets.all(18),
            topPadding: EdgeInsets.all(16),
          ),
          timePillar: const TimepillarLayout(
            fontSize: 40,
            width: 80,
            padding: 8,
            hourPadding: 1.5,
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
              textFieldActionButtonSpacing: 18),
          imageArchive: const ImageArchiveLayout(
              imageWidth: 142,
              imageHeight: 129,
              imagePadding: 6,
              imageNameBottomPadding: 3,
              fullscreenImagePadding: 18),
          libraryPage: const LibraryPageLayout(
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              crossAxisCount: 4,
              headerPadding: EdgeInsets.fromLTRB(24, 12, 0, 3),
              folderImagePadding: EdgeInsets.fromLTRB(15, 42, 15, 24),
              folderIconSize: 129,
              headerFontSize: 32,
              childAspectRatio: 181 / 168),
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
          checkList: const CheckListLayout(
            questionViewPadding: EdgeInsets.only(bottom: 12),
            questionIconPadding: EdgeInsets.only(right: 22),
            questionImagePadding: EdgeInsets.fromLTRB(10, 10, 0, 10),
            questionTitlePadding: EdgeInsets.only(left: 12, right: 16),
            addNewQButtonPadding: EdgeInsets.fromLTRB(18, 12, 18, 18),
            addNewQIconPadding: EdgeInsets.only(left: 22, right: 16),
            questionListPadding: EdgeInsets.fromLTRB(18, 18, 18, 0),
            questionViewHeight: 80,
            questionImageSize: 60,
            dividerHeight: 2,
            dividerIndentation: 16,
          ),
          note: const NoteLayout(
            notePadding: EdgeInsets.fromLTRB(27, 15, 24, 36),
          ),
          alarmPage: const AlarmPageLayout(
            alarmClockPadding: EdgeInsets.only(top: 6, bottom: 4, right: 24),
          ),
        );
}
