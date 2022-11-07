import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/utils/all.dart';

void main() {
  String dropGzipHeader(String base64) => base64.substring(14);
  group('deserialize', () {
    test('Empty returns empty list', () {
      expect(''.tryDecodeSignedOffDates(), []);
    });

    test('invalid returns null', () {
      expect('some random string'.tryDecodeSignedOffDates(), null);
    });

    test('Singel signed day', () {
      expect(
          'H4sIAAAAAAAAADMy0DUw0jU0AgD+M4d0CAAAAA=='.tryDecodeSignedOffDates(),
          ['20-02-12']);
    });
    test('Multiple singed off days', () {
      expect(
          'H4sIAAAAAAAAADMy0DUw0jU0tjYCM4wMYAxzAJhzqtsaAAAA'
              .tryDecodeSignedOffDates(),
          [
            '20-02-13',
            '20-02-20',
            '20-02-27',
          ]);
    });
  });

  group('serialize', () {
    test('Empty list return null', () {
      expect(<String>[].tryEncodeSignedOffDates(), null);
    });

    test('Singel signed day', () {
      expect(
          [DateTime(2020, 02, 12)]
              .map(whaleDateFormat)
              .tryEncodeSignedOffDates(),
          endsWith(dropGzipHeader(
              'H4sIAAAAAAAAADMy0DUw0jU0AgD+M4d0CAAAAA=='))); // drops gzip header
    });

    test('Multiple singed off days', () {
      expect(
          [
            DateTime(2020, 02, 13),
            DateTime(2020, 02, 20),
            DateTime(2020, 02, 27),
          ].map(whaleDateFormat).tryEncodeSignedOffDates(),
          endsWith(
            dropGzipHeader('H4sIAAAAAAAAADMy0DUw0jU0tjYCM4wMYAxzAJhzqtsaAAAA'),
          ));
    });
  });

  group('serialize then deserialize', () {
    test('corrupt date ignored', () {
      // Arrange
      final dates = [
        '01-01-01',
        '02-02-02',
        '03-03-03',
      ].toList()
        ..insert(1, 'invalid');
      // Act - Corrupt one data
      final invalidStringRep = dates.join(';');
      final encoded = invalidStringRep.zipAndEncode();
      final decoded = encoded.tryDecodeSignedOffDates();
      //Assert corrupt data ignored data
      expect(decoded, dates);
    });

    test('empty return null', () {
      // Arrange
      final dates = <DateTime>[];
      // Act
      final intermediet = dates.map(whaleDateFormat).tryEncodeSignedOffDates();
      final result = intermediet?.tryDecodeSignedOffDates();
      // Assert
      expect(result, null);
    });

    test('date return date', () {
      // Arrange
      final dates = [
        '20, 11, 11',
      ];
      // Act
      final intermediet = dates.tryEncodeSignedOffDates();
      final result = intermediet?.tryDecodeSignedOffDates();
      // Assert
      expect(result, dates);
    });

    test('dates return dates', () {
      // Arrange
      final dates = [
        '20-11-11',
        '20-12-11',
        '20-12-12',
        '20-01-01',
      ];
      // Act
      final intermediet = dates.tryEncodeSignedOffDates();
      final result = intermediet?.tryDecodeSignedOffDates();
      // Assert
      expect(result, dates);
    });
  });
}
