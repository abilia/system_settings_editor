import 'dart:async';
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/db/baseurl_db.dart';

class MyAbiliaConnection {
  Future<bool> hasConnection() async {
    bool isOnline = false;
    try {
      final baseUrl = GetIt.I<BaseUrlDb>().baseUrl;
      final result = await InternetAddress.lookup(
        baseUrl.replaceFirst('https://', ''),
      );
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    return isOnline;
  }
}
