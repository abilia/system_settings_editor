import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/l10n/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

void main() {
  group('minutes. five min interval', () {
    test('2 minutes past, first interval', () {
      expect(fiveMinInterval(DateTime(2021, 10, 25, 14, 02, 0)), 0);
    });

    test('3 minutes past, second interval', () {
      expect(fiveMinInterval(DateTime(2021, 10, 25, 14, 03, 0)), 1);
    });

    test('16 minutes past, third interval', () {
      expect(fiveMinInterval(DateTime(2021, 10, 25, 14, 16, 0)), 3);
    });

    test('29 minutes past, sixth interval', () {
      expect(fiveMinInterval(DateTime(2021, 10, 25, 14, 29, 0)), 6);
    });

    test('41 minutes past, eighth interval', () {
      expect(fiveMinInterval(DateTime(2021, 10, 25, 14, 41, 0)), 8);
    });

    test('53 minutes past, tenth interval', () {
      expect(fiveMinInterval(DateTime(2021, 10, 25, 14, 53, 0)), 11);
    });

    test('59 minutes past, first interval', () {
      expect(fiveMinInterval(DateTime(2021, 10, 25, 14, 59, 0)), 0);
    });
  });

  group('hours, basic cases', () {
    const languageCode = 'en';
    test('5 hours,', () {
      expect(hourForTime(languageCode, DateTime(2021, 10, 25, 5, 02, 0)), 5);
    });

    test('13 hours,', () {
      expect(hourForTime(languageCode, DateTime(2021, 10, 25, 13, 02, 0)), 1);
    });

    test('20 hours,', () {
      expect(hourForTime(languageCode, DateTime(2021, 10, 25, 20, 02, 0)), 8);
    });

    test('0 hours,', () {
      expect(hourForTime(languageCode, DateTime(2021, 10, 25, 0, 02, 0)), 12);
    });

    test('12 hours,', () {
      expect(hourForTime(languageCode, DateTime(2021, 10, 25, 12, 02, 0)), 12);
    });
  });

  group('hour, special cases', () {
    test('past 32 minutes, en', () {
      expect(hourForTime('en', DateTime(2021, 10, 25, 5, 33, 0)), 6);
    });

    test('past 17 minutes, nb', () {
      expect(hourForTime('nb', DateTime(2021, 10, 25, 5, 18, 0)), 6);
    });

    test('past 22 minutes, sv', () {
      expect(hourForTime('sv', DateTime(2021, 10, 25, 5, 23, 0)), 6);
    });

    test('past 22 minutes, da', () {
      expect(hourForTime('da', DateTime(2021, 10, 25, 5, 23, 0)), 6);
    });
  });

  group('time strings', () {
    test('Half past', () async {
      const locale = Locale('en');
      final translate = await Lt.load(locale);
      expect(
          analogTimeString(translate, locale, DateTime(2021, 10, 25, 5, 32, 0)),
          'Half past 5');
    });

    test('Ten to', () async {
      const locale = Locale('en');
      final translate = await Lt.load(locale);
      expect(
          analogTimeString(translate, locale, DateTime(2021, 10, 25, 4, 49, 0)),
          'ten to 5');
    });

    test('5 to half past', () async {
      const locale = Locale('en');
      final translate = await Lt.load(locale);
      expect(
          analogTimeString(translate, locale, DateTime(2021, 10, 25, 4, 24, 0)),
          'twenty five past 4');
    });

    test('en one o clock', () async {
      const locale = Locale('en');
      final translate = await Lt.load(locale);
      expect(
          analogTimeString(translate, locale, DateTime(2021, 10, 25, 1, 15, 0)),
          'quarter past 1 :');
    });

    test('nb one o clock', () async {
      const locale = Locale('en');
      final translate = await Lt.load(locale);
      expect(
          analogTimeString(translate, locale, DateTime(2021, 10, 25, 1, 15, 0)),
          'Kvart over : ett :');
    });

    test('sv half past 5', () async {
      const locale = Locale('en');
      final translate = await Lt.load(locale);
      expect(
          analogTimeString(translate, locale, DateTime(2021, 10, 25, 5, 29, 0)),
          'Halv 6');
    });
  });

  group('interval strings', () {
    test('morning', () async {
      expect(
          intervalString(
              await Lt.load(const Locale('en')), DayPart.morning, 11),
          '%s in the early morning');
    });

    test('day, fore-noon', () async {
      expect(intervalString(await Lt.load(const Locale('en')), DayPart.day, 11),
          '%s in the mid-morning');
    });

    test('day, afternoon', () async {
      expect(intervalString(await Lt.load(const Locale('en')), DayPart.day, 12),
          '%s in the afternoon');
    });

    test('evening', () async {
      expect(
          intervalString(
              await Lt.load(const Locale('en')), DayPart.evening, 11),
          '%s in the evening');
    });

    test('night', () async {
      expect(
          intervalString(await Lt.load(const Locale('en')), DayPart.night, 20),
          '%s at night');
    });
  });
}
