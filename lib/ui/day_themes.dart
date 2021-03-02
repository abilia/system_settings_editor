import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DayTheme {
  final ThemeData theme;
  final Color color, backgroundColor;

  DayTheme._(
    ThemeData theme,
    this.color,
    bool background,
  )   : backgroundColor = background
            ? Color.alphaBlend(const Color(0x33000000), color)
            : null,
        theme = theme.copyWith(
            appBarTheme: theme.appBarTheme.copyWith(color: color));

  DayTheme._light(Color color, {bool background = true})
      : this._(_lightAppBarTheme, color, background);

  DayTheme._dark(Color color, {bool background = true})
      : this._(_darkAppBarTheme, color, background);

  ThemeData get withScaffoldBackgroundColor =>
      theme.copyWith(scaffoldBackgroundColor: backgroundColor);
}

final _noColor = DayTheme._light(AbiliaColors.black80, background: false),
    _white = DayTheme._dark(AbiliaColors.white, background: false),
    _red = DayTheme._light(AbiliaColors.sundayRed),
    _monday = DayTheme._light(AbiliaColors.green),
    _blue = DayTheme._light(AbiliaColors.blue),
    _thursday = DayTheme._light(AbiliaColors.thursdayBrown),
    _friday = DayTheme._dark(AbiliaColors.yellow),
    _saturday = DayTheme._light(AbiliaColors.pink),
    _danishTuesday = DayTheme._light(AbiliaColors.purple60),
    _danishWednesDay = DayTheme._light(AbiliaColors.orange120);

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

ThemeData _lightAppBarTheme = lightButtonTheme.copyWith(
  appBarTheme: abiliaTheme.appBarTheme.copyWith(
    brightness: Brightness.dark,
  ),
  textTheme: abiliaTextTheme.copyWith(
    headline6: abiliaTextTheme.headline6.copyWith(color: AbiliaColors.white),
    button: abiliaTextTheme.button.copyWith(color: AbiliaColors.white),
    subtitle1: abiliaTextTheme.subtitle1.copyWith(color: AbiliaColors.white),
  ),
);

ThemeData _darkAppBarTheme = darkButtonTheme.copyWith(
  primaryColor: AbiliaColors.white,
  appBarTheme: abiliaTheme.appBarTheme.copyWith(
    brightness: Brightness.light,
  ),
);
