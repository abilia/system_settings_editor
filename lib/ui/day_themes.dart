import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DayTheme {
  final ThemeData theme;
  final Color color, secondaryColor, borderColor;
  final bool isColor;
  Color get dayColor => isColor ? color : null;

  DayTheme._(
    ThemeData theme,
    this.color,
    this.secondaryColor,
    bool background, {
    Color accentColor,
    this.isColor = true,
  })  : borderColor =
            color == AbiliaColors.white ? AbiliaColors.white110 : color,
        theme = theme.copyWith(
          appBarTheme: theme.appBarTheme.copyWith(color: color),
          scaffoldBackgroundColor: background
              ? Color.alphaBlend(const Color(0x33000000), color)
              : null,
          accentColor: accentColor,
        );

  DayTheme._light(
    Color color,
    Color secondaryColor, {
    Color accentColor,
    background = true,
    isColor = true,
  }) : this._(
          _lightAppBarTheme,
          color,
          secondaryColor,
          background,
          accentColor: accentColor,
          isColor: isColor,
        );

  DayTheme._dark(Color color, Color secondaryColor, {bool background = true})
      : this._(_darkAppBarTheme, color, secondaryColor, background);
}

final _noColor = DayTheme._light(
      AbiliaColors.black80,
      AbiliaColors.white110,
      accentColor: AbiliaColors.white,
      background: false,
      isColor: false,
    ),
    _white = DayTheme._dark(AbiliaColors.white, AbiliaColors.white110,
        background: false),
    _red = DayTheme._light(AbiliaColors.sundayRed, AbiliaColors.sundayRed40),
    _monday = DayTheme._light(AbiliaColors.green, AbiliaColors.mondayGreen40),
    _blue = DayTheme._light(AbiliaColors.blue, AbiliaColors.tuesdayBlue40),
    _thursday = DayTheme._light(
        AbiliaColors.thursdayBrown, AbiliaColors.thursdayBrown40),
    _friday = DayTheme._dark(AbiliaColors.yellow, AbiliaColors.fridayYellow40),
    _saturday = DayTheme._light(AbiliaColors.pink, AbiliaColors.saturdayPink40),
    _danishTuesday =
        DayTheme._light(AbiliaColors.purple60, AbiliaColors.purple60),
    _danishWednesDay =
        DayTheme._light(AbiliaColors.orange120, AbiliaColors.orange120);

DayTheme weekdayTheme({
  @required DayColor dayColor,
  @required String languageCode,
  @required int weekday,
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
      return _danishWednesDay;
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
    brightness: Brightness.dark,
  ),
  textTheme: abiliaTextTheme.apply(
    displayColor: AbiliaColors.white,
    bodyColor: AbiliaColors.white,
  ),
  textButtonTheme: TextButtonThemeData(style: actionButtonStyleLight),
);

ThemeData _darkAppBarTheme = abiliaTheme.copyWith(
  primaryColor: AbiliaColors.white,
  appBarTheme: abiliaTheme.appBarTheme.copyWith(
    brightness: Brightness.light,
  ),
  textButtonTheme: TextButtonThemeData(style: actionButtonStyleDark),
);
