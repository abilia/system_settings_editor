import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/settings/memoplanner_settings_enums.dart';
import 'package:memoplanner/ui/all.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test('Test danish tuesday not same as others', () {
    final danishTheme = weekdayTheme(
        dayColor: DayColor.allDays,
        languageCode: 'da',
        weekday: DateTime.tuesday);
    final englishTheme = weekdayTheme(
        dayColor: DayColor.allDays,
        languageCode: 'en',
        weekday: DateTime.tuesday);

    expect(false, danishTheme.dayColor == englishTheme.dayColor);
  });

  test('Test danish wednesday not same as others', () {
    final danishTheme = weekdayTheme(
        dayColor: DayColor.allDays,
        languageCode: 'da',
        weekday: DateTime.wednesday);
    final englishTheme = weekdayTheme(
        dayColor: DayColor.allDays,
        languageCode: 'en',
        weekday: DateTime.wednesday);

    expect(false, danishTheme.dayColor == englishTheme.dayColor);
  });

  test('Test danish secondary day colors not same as primary', () {
    DayTheme theme;
    for (int i = 1; i < 8; i++) {
      theme = weekdayTheme(
          dayColor: DayColor.allDays, languageCode: 'da', weekday: i);
      if (theme.dayColor != null) {
        expect(false, theme.dayColor == theme.secondaryColor);
      }
    }
  });
}
