import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/utils/all.dart';

void main() {
  final date1 = DateTime(2022, 01, 20);
  final date2 = DateTime(2022, 12, 01);
  final date3 = DateTime(1, 1, 1, 1, 1);

  setUpAll(() async => await initializeDateFormatting());

  test('US locale creates correct image name', () {
    Intl.defaultLocale = 'en_US';
    final name1 = getImageName('en_US', date1);
    final name2 = getImageName('en_US', date2);
    final name3 = getImageName('en_US', date3);
    expect(name1, '1/20/2022');
    expect(name2, '12/1/2022');
    expect(name3, '1/1/1');
  });

  test('UK locale creates correct image name', () async {
    Intl.defaultLocale = 'en_GB';
    final name1 = getImageName('en_GB', date1);
    final name2 = getImageName('en_GB', date2);
    final name3 = getImageName('en_GB', date3);
    expect(name1, '20/01/2022');
    expect(name2, '01/12/2022');
    expect(name3, '01/01/1');
  });

  test('Swedish locale creates correct image name', () {
    Intl.defaultLocale = 'sv_SE';
    final name1 = getImageName('sv_SE', date1);
    final name2 = getImageName('sv_SE', date2);
    final name3 = getImageName('sv_SE', date3);
    expect(name1, '2022-01-20');
    expect(name2, '2022-12-01');
    expect(name3, '1-01-01');
  });
}
