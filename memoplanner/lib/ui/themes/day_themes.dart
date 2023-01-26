import 'package:flutter/services.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class DayTheme {
  final ThemeData theme;
  final Color color, secondaryColor, monthColor, monthSurfaceColor;
  final Color? borderColor;
  final bool isColor, isLight;

  Color? get dayColor => isColor ? color : null;

  CrossOverStyle get crossOverStyle =>
      isLight ? CrossOverStyle.lightDefault : CrossOverStyle.darkDefault;

  DayTheme._(
    ThemeData theme,
    this.color,
    this.secondaryColor,
    bool background, {
    required this.isLight,
    Color? onSurface,
    this.isColor = true,
    Color? monthColor,
    Color? monthSurfaceColor,
    this.borderColor,
  })  : theme = theme.copyWith(
          appBarTheme: theme.appBarTheme.copyWith(color: color),
          scaffoldBackgroundColor: background
              ? Color.alphaBlend(const Color(0x33000000), color)
              : null,
          colorScheme: theme.colorScheme.copyWith(onSurface: onSurface),
        ),
        monthColor = monthColor ?? color,
        monthSurfaceColor = monthSurfaceColor ?? theme.colorScheme.onSurface;

  DayTheme._light(
    Color color,
    Color secondaryColor, {
    Color? onSurface,
    bool background = true,
    bool isColor = true,
    Color? monthColor,
    Color monthSurfaceColor = AbiliaColors.white,
  }) : this._(
          _lightAppBarTheme,
          color,
          secondaryColor,
          background,
          onSurface: onSurface,
          isColor: isColor,
          isLight: true,
          monthColor: monthColor,
          monthSurfaceColor: monthSurfaceColor,
        );

  DayTheme._dark(
    Color color,
    Color secondaryColor, {
    bool background = true,
    Color? borderColor,
  }) : this._(
          _darkAppBarTheme,
          color,
          secondaryColor,
          background,
          isLight: false,
          borderColor: borderColor,
        );
}

final _noColor = DayTheme._light(
      AbiliaColors.black80,
      AbiliaColors.white,
      onSurface: AbiliaColors.white,
      background: false,
      isColor: false,
      monthColor: AbiliaColors.white,
      monthSurfaceColor: AbiliaColors.black,
    ),
    _white = DayTheme._dark(AbiliaColors.white110, AbiliaColors.white,
        borderColor: AbiliaColors.white120, background: false),
    _red = DayTheme._light(AbiliaColors.sundayRed, AbiliaColors.sundayRed40),
    _monday = DayTheme._light(AbiliaColors.green, AbiliaColors.mondayGreen40),
    _blue = DayTheme._light(AbiliaColors.blue, AbiliaColors.tuesdayBlue40),
    _thursday = DayTheme._light(
        AbiliaColors.thursdayBrown, AbiliaColors.thursdayBrown40),
    _friday = DayTheme._dark(AbiliaColors.yellow, AbiliaColors.fridayYellow40),
    _saturday = DayTheme._light(AbiliaColors.pink, AbiliaColors.saturdayPink40),
    _danishTuesday =
        DayTheme._light(AbiliaColors.purple60, AbiliaColors.purple40),
    _danishWednesday =
        DayTheme._light(AbiliaColors.orange120, AbiliaColors.orange60);

DayTheme weekdayTheme({
  required DayColor dayColor,
  required String languageCode,
  required int weekday,
}) {
  final noColors = dayColor == DayColor.noColors ||
      dayColor == DayColor.saturdayAndSunday && weekday < DateTime.saturday;

  if (noColors) return _noColor;

  if (languageCode == 'da') return _danish(weekday);

  return _international(weekday);
}

DayTheme _international(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return _monday;
    case DateTime.tuesday:
      return _blue;
    case DateTime.wednesday:
      return _white;
    case DateTime.thursday:
      return _thursday;
    case DateTime.friday:
      return _friday;
    case DateTime.saturday:
      return _saturday;
    case DateTime.sunday:
      return _red;
    default:
      return _noColor;
  }
}

DayTheme _danish(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return _monday;
    case DateTime.tuesday:
      return _danishTuesday;
    case DateTime.wednesday:
      return _danishWednesday;
    case DateTime.thursday:
      return _blue;
    case DateTime.friday:
      return _friday;
    case DateTime.saturday:
      return _red;
    case DateTime.sunday:
      return _white;
    default:
      return _noColor;
  }
}

ThemeData _lightAppBarTheme = abiliaTheme.copyWith(
  appBarTheme: abiliaTheme.appBarTheme.copyWith(
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  textTheme: abiliaTextTheme
      .copyWith(
        titleLarge: layout.appBar.textStyle,
      )
      .apply(
        displayColor: AbiliaColors.white,
        bodyColor: AbiliaColors.white,
      ),
  textButtonTheme: TextButtonThemeData(style: actionButtonStyleLightLarge),
);

ThemeData _darkAppBarTheme = abiliaTheme.copyWith(
  primaryColor: AbiliaColors.white,
  appBarTheme: abiliaTheme.appBarTheme.copyWith(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  textTheme: abiliaTextTheme
      .copyWith(
        titleLarge: layout.appBar.textStyle,
      )
      .apply(
        displayColor: AbiliaColors.black,
        bodyColor: AbiliaColors.black,
      ),
  textButtonTheme: TextButtonThemeData(style: actionButtonStyleDarkLarge),
);
