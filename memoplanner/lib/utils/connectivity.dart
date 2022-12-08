import 'dart:io';

typedef ConnectivityCheck = Future<bool> Function(String endpoint);

Future<bool> hasConnection(String endpoint) async {
  try {
    final result = await InternetAddress.lookup(
      endpoint.replaceFirst(RegExp(r'^https?://'), ''),
    );
    return result.any((element) => element.rawAddress.isNotEmpty);
  } catch (_) {
    return false;
  }
}
