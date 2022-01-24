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
            marginSmall: 8,
            marginLarge: 16,
            imageSize: 88,
            categorySideOffset: 120,
            iconSize: 24.0,
            imagePadding: EdgeInsets.only(left: 8),
            crossPadding: EdgeInsets.all(8),
            titlePadding:
                EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 16),
            statusesPadding: EdgeInsets.only(right: 12, bottom: 8),
          ),
          timerPage: const TimerPageLayout(
            topInfoHeight: 232,
            topVerticalPadding: 16,
            topHorizontalPadding: 16,
            imageSize: 200,
            imagePadding: 16,
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
              minHeight: 140,
              imageHeightMin: 96,
              margin: 8,
              padding: 17,
            ),
            twoTimePillar: TwoTimepillarLayout(
              verticalMargin: 36,
              nightMargin: 6,
              radius: 18,
            ),
          ),
          imageArchive: const ImageArchiveLayout(
              imageWidth: 142,
              imageHeight: 142,
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
              childAspectRatio: 1.07),
        );
}
