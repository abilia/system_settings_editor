import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class SyncResponse extends Equatable {
  final String id;
  final int oldRevision;
  final int newRevision;

  SyncResponse({
    @required this.id,
    @required this.oldRevision,
    @required this.newRevision,
  });

  @override
  List<Object> get props => [id, oldRevision, newRevision];

  static SyncResponse fromJson(Map<String, dynamic> data) {
    return SyncResponse(
      id: data['id'],
      oldRevision: data['oldRevision'],
      newRevision: data['newRevision'],
    );
  }
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
