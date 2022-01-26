import 'dart:convert';

import 'package:http/http.dart';

extension JsonResponse on Response {
  String jsonString() => utf8.decode(bodyBytes);
  dynamic json() => jsonDecode(jsonString());
}
