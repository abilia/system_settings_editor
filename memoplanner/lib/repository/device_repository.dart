import 'dart:convert';

import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class DeviceRepository extends Repository {
  DeviceRepository({
    required super.client,
    required super.baseUrlDb,
    required this.deviceDb,
  });

  final DeviceDb deviceDb;

  Future<bool> verifyDevice(
      String serialId, String clientId, String licenseKey) async {
    final url = '$baseUrl/open/v1/device/$serialId/verify';
    final response = await client.post(
      url.toUri(),
      headers: jsonHeaderWithKey,
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

  Uri get licenseUrl => '$baseUrl/open/v1/device/$serialId/license'.toUri();
  Future<LicenseResponse> checkLicense() async {
    final response = await client.get(licenseUrl);
    return _parseLicenseResponse(response);
  }

  Future<LicenseResponse> connectWithLicense(String licenseKey) async {
    final response = await client.post(
      licenseUrl,
      headers: jsonHeaderWithKey,
      body: json.encode({'licenseNumber': licenseKey}),
    );
    return _parseLicenseResponse(response);
  }

  LicenseResponse _parseLicenseResponse(Response response) {
    final responseJson = response.json();
    switch (response.statusCode) {
      case 200:
        return LicenseResponse.fromJson(responseJson);
      case 400:
      case 404:
      case 409:
        throw ConnectedLicenseException(
          badRequest: BadRequest.fromJson(responseJson),
        );
      default:
        throw Exception('Unknown error when parsing license response');
    }
  }

  Future<void> setSerialId(String serialId) => deviceDb.setSerialId(serialId);
  String get serialId => deviceDb.serialId;
  Future<String> getClientId() => deviceDb.getClientId();
  Future<void> setStartGuideCompleted([bool complete = true]) =>
      deviceDb.setStartGuideCompleted(complete);
  bool get isStartGuideCompleted => deviceDb.startGuideCompleted;
}
