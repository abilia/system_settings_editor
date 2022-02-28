import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/repository/json_response.dart';
import 'package:seagull/utils/strings.dart';

class DeviceRepository extends Repository {
  DeviceRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.deviceDb,
  }) : super(client, baseUrlDb);

  final DeviceDb deviceDb;

  Future<bool> verifyDevice(String serialId, String clientId) async {
    final url = '$baseUrl/open/v1/enrollment/verify-device/$serialId';
    final response = await client.post(
      url.toUri(),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'api-key': 'huyf72P00mf8Hy53k',
      },
      body: json.encode({'clientId': clientId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else if (response.statusCode == 400) {
      throw VerifyDeviceException(
          badRequest: BadRequest.fromJson(response.json()));
    } else {
      throw Exception('Unknown error when verifying device id');
    }
  }

  Future<void> setSerialId(String serialId) => deviceDb.setSerialId(serialId);
  Future<String> getClientId() => deviceDb.getClientId();
}
