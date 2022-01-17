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
          monthCalendarLayout: const MonthCalendarLayout(
              monthContentFlex: 620,
              monthListPreviewFlex: 344,
              weekRowVerticalPadding: 4,
              monthHeadingHeight: 48,
              monthDayRadius: 12,
              weekNumberWidth: 36,
              hasActivitiesDotDiameter: 10,
              currentBorderWidth: 6,
              weekNumberPadding: EdgeInsets.symmetric(horizontal: 4),
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
                dayViewCompactPadding: EdgeInsets.all(8),
                compactCrossOverPadding: EdgeInsets.all(3),
              )),
        );
}
