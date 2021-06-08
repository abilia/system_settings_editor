// @dart=2.9

import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class MultipartRequestBuilder {
  MultipartRequest generateFileMultipartRequest({
    @required Uri uri,
    @required Uint8List bytes,
    @required String authToken,
    @required String sha1,
  }) =>
      MultipartRequest('POST', uri)
        ..files.add(MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'test.jpg',
        ))
        ..headers['X-Auth-Token'] = authToken
        ..fields.addAll({
          'sha1': sha1,
        });
}
