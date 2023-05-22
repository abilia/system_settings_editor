import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

String whaleDateFormat(DateTime date) {
  String twoDigits(int n) => (n >= 10) ? '$n' : '0$n';
  final year = twoDigits(date.year % 100);
  final month = twoDigits(date.month);
  final day = twoDigits(date.day);
  return '$year-$month-$day';
}

extension EncodeSignOffDates on Iterable<String> {
  String? tryEncodeSignedOffDates() {
    if (isEmpty != false) return null;
    return join(';').zipAndEncode();
  }
}

extension DeserializeSignOffDates on String {
  Set<String>? tryDecodeSignedOffDates() =>
      tryUnzipAndDecode()?.split(';').where((s) => s.isNotEmpty).toSet();

  @visibleForTesting
  String? tryUnzipAndDecode() {
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
