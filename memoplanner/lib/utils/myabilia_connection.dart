import 'dart:async';

import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/utils/all.dart';

class MyAbiliaConnection {
  MyAbiliaConnection({
    required this.baseUrlDb,
    required this.client,
  });
  final BaseUrlDb baseUrlDb;
  final Client client;
  Future<bool> hasConnection() async {
    final url = '${baseUrlDb.baseUrl}/open/v1/monitor/basic'.toUri();
    try {
      final response = await client.head(url);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
