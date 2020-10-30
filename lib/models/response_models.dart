import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

class SyncResponse extends DataRevisionUpdates {
  final int oldRevision;

  SyncResponse({
    @required String id,
    @required int revision,
    @required this.oldRevision,
  }) : super(id, revision);

  @override
  List<Object> get props => [id, oldRevision, revision];

  static SyncResponse fromJson(Map<String, dynamic> data) => SyncResponse(
        id: data['id'],
        oldRevision: data['oldRevision'],
        revision: data['newRevision'],
      );
}

class ResponseError {
  final String code;
  final String message;

  ResponseError({
    @required this.code,
    @required this.message,
  });

  static ResponseError fromJson(Map<String, dynamic> data) {
    return ResponseError(code: data['code'], message: data['message']);
  }
}

class ErrorCodes {
  static const String WRONG_REVISION = 'WHALE-0900';
}
