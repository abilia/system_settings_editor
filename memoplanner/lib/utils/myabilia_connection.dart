import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/db/baseurl_db.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/repository/http_client.dart';
import 'package:memoplanner/utils/all.dart';

class MyAbiliaConnection {
  Future<bool> hasConnection() async {
    final client = GetIt.I<ListenableClient>();
    final url = '${GetIt.I<BaseUrlDb>().baseUrl}/open/v1/monitor/basic';

    try {
      final response = await client.get(url.toUri());
      return response.body == 'ok';
    } catch (_) {
      return false;
    }
  }
}
