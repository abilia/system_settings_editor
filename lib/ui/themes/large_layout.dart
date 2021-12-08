part of 'layout.dart';

class _LargeLayout extends Layout {
  const _LargeLayout()
      : super(
          appbar: const AppBarLayout(
            height: 225,
          ),
          actionButton: const ActionButtonLayout(
            size: 100,
            radius: 22,
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
            caption: 12,
            button: 24,
            overline: 10,
          ),
        );
}
