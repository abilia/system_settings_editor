import 'dart:collection';

import 'package:equatable/equatable.dart';

class DataUpdateResponse extends Equatable {
  final int previousRevision;
  final UnmodifiableListView<DataRevisionUpdate> succeded, failed;

  DataUpdateResponse.fromJson(Map<String, dynamic> json)
      : previousRevision = json['previousRevision'],
        failed = _parseDataRevisionUpdates(json['failedUpdates']),
        succeded = _parseDataRevisionUpdates(json['dataRevisionUpdates']);

  static UnmodifiableListView<DataRevisionUpdate> _parseDataRevisionUpdates(
          List? jsonList) =>
      UnmodifiableListView(jsonList
              ?.whereType<Map<String, dynamic>>()
              .map(DataRevisionUpdate.fromJson) ??
          []);
  @override
  String toString() =>
      'ActivityUpdateResponse { previousRevision: $previousRevision, succeded: $succeded, failed: $failed }';

  @override
  List<Object> get props => [previousRevision, succeded, failed];
  @override
  bool get stringify => true;
}

class DataRevisionUpdate extends Equatable {
  final String id;
  final int revision, oldRevision;
  const DataRevisionUpdate({
    required this.id,
    required this.revision,
    required this.oldRevision,
  });
  static DataRevisionUpdate fromJson(Map<String, dynamic> json) =>
      DataRevisionUpdate(
        id: json['id'],
        revision: json['newRevision'],
        oldRevision: json['oldRevision'],
      );

  @override
  List<Object> get props => [id, revision];
  @override
  bool get stringify => true;
}

class ResponseError {
  final String code;
  final String message;

  ResponseError({
    required this.code,
    required this.message,
  });

  static ResponseError fromJson(Map<String, dynamic> data) {
    return ResponseError(
        code: data['code'] ?? '', message: data['message'] ?? '');
  }
}

class ErrorCodes {
  static const String WRONG_REVISION = 'WHALE-0900';
}
