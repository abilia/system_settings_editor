import 'dart:async';

import 'package:http/http.dart';
import 'package:repository_base/repository_base.dart';

class MyAbiliaConnection {
  MyAbiliaConnection({
    required this.baseUrlDb,
    required this.client,
  });
  final BaseUrlDb baseUrlDb;
  final Client client;
  Future<bool> hasConnection() async {
    final url = Uri.parse('${baseUrlDb.baseUrl}/open/v1/monitor/basic');
    try {
      final response = await client.head(url);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
