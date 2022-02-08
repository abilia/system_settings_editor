import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/repository/json_response.dart';
import 'package:seagull/utils/strings.dart';

class SerialIdRepository extends Repository {
  SerialIdRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.serialIdDb,
  }) : super(client, baseUrlDb);

  final SerialIdDb serialIdDb;

  Future<bool> verifyDevice(String serialId) async {
    final url = '$baseUrl/open/v1/enrollment/verify-device/$serialId';
    final response = await client.post(
      url.toUri(),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(
        {
          'clientId': serialIdDb.getClientId(),
        },
      ),
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

  Future<void> setSerialId(String serialId) => serialIdDb.setSerialId(serialId);
  String? getSerialId() => serialIdDb.getSerialId();

  Future<void> setClientId(String clientId) => serialIdDb.setClientId(clientId);
  String? getClientId() => serialIdDb.getClientId();
}
