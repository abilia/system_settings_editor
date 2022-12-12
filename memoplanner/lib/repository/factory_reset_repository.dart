import 'dart:convert';

import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class FactoryResetRepository extends Repository {
  final Logger _log = Logger((FactoryResetRepository).toString());
  final DeviceDb deviceDb;

  FactoryResetRepository({
    required this.deviceDb,
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
  }) : super(client, baseUrlDb);

  String get _serialId => deviceDb.serialId;

  Uri get endpoint => '$baseUrl/open/v1/device/$_serialId/reset'.toUri();

  Future<bool> factoryResetDevice() async {
    final clientId = await deviceDb.getClientId();
    try {
      final response = await client.post(
        endpoint,
        headers: jsonHeaderWithKey,
        body: jsonEncode({
          'clientId': clientId,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      }
      _log.warning(
        'Could not factory reset $_serialId with status code '
        '${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      _log.warning('Could not factory reset $_serialId from backend $e');
    }
    return false;
  }
}
