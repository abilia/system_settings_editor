import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

@visibleForTesting
String whaleDateFormat(DateTime date) {
  String _twoDigits(int n) => (n >= 10) ? '$n' : '0$n';
  final year = _twoDigits(date.year % 100);
  final month = _twoDigits(date.month);
  final day = _twoDigits(date.day);
  return '$year-$month-$day';
}

extension EncodeSignOffDates on Iterable<DateTime> {
  String tryEncodeSignedOffDates() {
    if (this == null || isEmpty != false) return null;
    return map(whaleDateFormat).join(';').zipAndEncode();
  }
}

extension DeserializeSignOffDates on String {
  Iterable<DateTime> tryDecodeSignedOffDates() => tryUnzipAndDecode()
      ?.split(';')
      ?.map((d) => '20' + d)
      ?.map(DateTime.tryParse)
      ?.where((d) => d != null);

  @visibleForTesting
  String tryUnzipAndDecode() {
    try {
      return unzipAndDecode();
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  String unzipAndDecode() => utf8.decode(gzip.decode(base64Decode(this)));

  @visibleForTesting
  String zipAndEncode() => base64Encode(gzip.encode(utf8.encode(this)));
}
