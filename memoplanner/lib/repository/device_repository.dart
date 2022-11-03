import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class DeviceRepository extends Repository {
  DeviceRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.deviceDb,
  }) : super(client, baseUrlDb);

  final DeviceDb deviceDb;

  Future<bool> verifyDevice(
      String serialId, String clientId, String licenseKey) async {
    final url = '$baseUrl/open/v1/enrollment/verify-device/$serialId';
    final response = await client.post(
      url.toUri(),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'api-key': 'huyf72P00mf8Hy53k',
      },
      body: json.encode({
        'clientId': clientId,
        'licenseKey': licenseKey,
      }),
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
  String get serialId => deviceDb.serialId;
  Future<String> getClientId() => deviceDb.getClientId();
  Future<void> setStartGuideCompleted([bool complete = true]) =>
      deviceDb.setStartGuideCompleted(complete);
  bool get isStartGuideCompleted => deviceDb.startGuideCompleted;
}
