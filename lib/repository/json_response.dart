import 'dart:convert';

import 'package:http/http.dart';

extension JsonResponse on Response {
  dynamic json() => jsonDecode(utf8.decode(bodyBytes));
}
