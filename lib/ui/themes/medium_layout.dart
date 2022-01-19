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
          activityCard: const ActivityCardLayout(
            height: 104,
            padding: 8,
            paddingBottom: 8,
            marginSmall: 8,
            marginLarge: 16,
            imageSize: 88,
            categorySideOffset: 120,
            iconSize: 24.0,
            titleImagePadding: 12,
          ),
          timePillar: const TimepillarLayout(
            imageHeightMin: 96,
            cardPadding: 8,
            width: 110,
            padding: 17,
            minHeight: 112,
            dotSize: 16,
            hourPadding: 1.5,
            dotPadding: 4.5,
            dotDistance: 20.5,
            timePillarPadding: 8,
            defaultTimePillarWidth: 80,
            fontSize: 40, // no matching font size. defined in separate ticket
            fontWeight: FontWeight.w900, // needs to be high to match design
          ),
        );
}
