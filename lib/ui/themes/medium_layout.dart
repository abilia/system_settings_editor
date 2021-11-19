import 'all.dart';

class MediumLayout extends Lay {
  const MediumLayout()
      : super(
          appBar: const AppBarLayout(
            height: 148,
          ),
          actionButton: const ActionButtonLayout(
            size: 88,
            radius: 20,
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
          font: const FontSize(
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
            caption: 18,
            button: 24,
            overline: 15,
          ),
          icon: const IconSize(
            small: 48,
            button: 56,
            normal: 64,
            large: 96,
            huge: 192,
          ),
        );
}
