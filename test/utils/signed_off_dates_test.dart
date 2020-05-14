import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/utils/signed_off_dates.dart';

void main() {
  String dropGzipHeader(String base64) => base64.substring(14);
  group('deserialize', () {
    test('Empty returns empty list', () {
      expect(''.tryDecodeSignedOffDates(), []);
    });
    test('null returns null', () {
      expect(null.tryDecodeSignedOffDates(), null);
    });
    test('invalid returns null', () {
      expect('some random string'.tryDecodeSignedOffDates(), null);
    });
    test('Singel signed day', () {
      expect(
          'H4sIAAAAAAAAADMy0DUw0jU0AgD+M4d0CAAAAA=='.tryDecodeSignedOffDates(),
          [DateTime(2020, 02, 12)]);
    });
    test('Multiple singed off days', () {
      expect(
          'H4sIAAAAAAAAADMy0DUw0jU0tjYCM4wMYAxzAJhzqtsaAAAA'
              .tryDecodeSignedOffDates(),
          [
            DateTime(2020, 02, 13),
            DateTime(2020, 02, 20),
            DateTime(2020, 02, 27),
          ]);
    });
  });
  group('serialize', () {
    test('Empty list return null', () {
      expect(<DateTime>[].tryEncodeSignedOffDates(), null);
    });

    test('null returns null', () {
      expect(null.tryEncodeSignedOffDates(), null);
    });
    test('Singel signed day', () {
      expect(
          [DateTime(2020, 02, 12)].tryEncodeSignedOffDates(),
          endsWith(dropGzipHeader(
              'H4sIAAAAAAAAADMy0DUw0jU0AgD+M4d0CAAAAA=='))); // drops gzip header
    });
    test('Multiple singed off days', () {
      expect(
          [
            DateTime(2020, 02, 13),
            DateTime(2020, 02, 20),
            DateTime(2020, 02, 27),
          ].tryEncodeSignedOffDates(),
          endsWith(
            dropGzipHeader('H4sIAAAAAAAAADMy0DUw0jU0tjYCM4wMYAxzAJhzqtsaAAAA'),
          ));
    });
  });
  group('serialize then deserialize', () {
    test('null return null', () {
      expect(null.tryEncodeSignedOffDates().tryDecodeSignedOffDates(), null);
    });

    test('corrupt date ignored', () {
      // Arrange
      final dates = [
        DateTime(2001, 01, 01),
        DateTime(2002, 02, 02),
        DateTime(2003, 03, 03)
      ];
      // Act - Corrupt one data
      final invalidStringRep =
          (dates.map(whaleDateFormat).toList()..insert(1, 'invalid')).join(';');
      final encoded = invalidStringRep.zipAndEncode();
      final decoded = encoded.tryDecodeSignedOffDates();
      //Assert corrupt data ignored data
      expect(decoded, dates);
    });

    test('empty return null', () {
      // Arrange
      final dates = <DateTime>[];
      // Act
      final intermediet = dates.tryEncodeSignedOffDates();
      final result = intermediet.tryDecodeSignedOffDates();
      // Assert
      expect(result, null);
    });

    test('date return date', () {
      // Arrange
      final dates = [
        DateTime(2020, 11, 11),
      ];
      // Act
      final intermediet = dates.tryEncodeSignedOffDates();
      final result = intermediet.tryDecodeSignedOffDates();
      // Assert
      expect(result, dates);
    });
    test('dates return dates', () {
      // Arrange
      final dates = [
        DateTime(2020, 11, 11),
        DateTime(2020, 12, 11),
        DateTime(2020, 12, 12),
        DateTime(2020, 01, 01),
      ];
      // Act
      final intermediet = dates.tryEncodeSignedOffDates();
      final result = intermediet.tryDecodeSignedOffDates();
      // Assert
      expect(result, dates);
    });
  });
}
