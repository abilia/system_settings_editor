part of 'layout.dart';

class _MediumLayout extends Layout {
  const _MediumLayout()
      : super(
          appBar: const AppBarLayout(
            height: 148,
          ),
          actionButton: const ActionButtonLayout(
            size: 88,
            radius: 20,
            spacing: 4,
            padding: EdgeInsets.all(12),
            withTextPadding: EdgeInsets.only(left: 6, top: 6, right: 6),
          ),
          toolbar: const ToolbarLayout(
            heigth: 120,
            bottomPadding: 8,
          ),
          tabBar: const TabBarLayout(
            item: TabItemLayout(
              width: 118,
              border: 2,
            ),
            heigth: 104,
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
          monthCalendar: const MonthCalendarLayout(
              monthContentFlex: 620,
              monthListPreviewFlex: 344,
              monthHeadingHeight: 48,
              dayRadius: 12,
              dayRadiusHighlighted: 14,
              dayBorderWidth: 2,
              dayBorderWidthHighlighted: 6,
              dayHeaderHeight: 28,
              dayHeaderHeightHighlighted: 31,
              weekNumberWidth: 36,
              hasActivitiesDotDiameter: 10,
              dayHeadingFontSize: 20,
              dayViewMargin: EdgeInsets.all(4),
              dayViewMarginHighlighted: EdgeInsets.all(1),
              dayViewPadding:
                  EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 6),
              dayViewPaddingHighlighted:
                  EdgeInsets.only(left: 9, right: 9, top: 4, bottom: 9),
              dayHeaderPadding: EdgeInsets.only(left: 6, right: 6, top: 6),
              dayHeaderPaddingHighlighted:
                  EdgeInsets.only(left: 9, right: 9, top: 9),
              hasActivitiesDotPadding: EdgeInsets.only(top: 2),
              monthPreview: MonthPreviewLayout(
                monthPreviewBorderWidth: 2,
                activityListTopPadding: 32,
                activityListBottomPadding: 96,
                headingHeight: 72,
                headingFullDayActivityHeight: 54,
                headingFullDayActivityWidth: 57,
                monthListPreviewPadding: EdgeInsets.only(
                    left: 12,
                    top: 32,
                    right:
                        12), //TODO: sannolikt skall denna ändras, kolla mot designen
                headingPadding: EdgeInsets.only(left: 18, right: 16),
              )),
        );
}
