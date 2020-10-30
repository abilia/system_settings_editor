import 'dart:collection';

import 'package:equatable/equatable.dart';

class DataUpdateResponse extends Equatable {
  final int previousRevision;
  final UnmodifiableListView<DataRevisionUpdates> succeded, failed;

  DataUpdateResponse.fromJson(Map<String, dynamic> json)
      : previousRevision = json['previousRevision'],
        failed = _parseDataRevisionUpdates(json['failedUpdates']),
        succeded = _parseDataRevisionUpdates(json['dataRevisionUpdates']);

  static UnmodifiableListView<DataRevisionUpdates> _parseDataRevisionUpdates(
          List jsonList) =>
      UnmodifiableListView(jsonList
              ?.whereType<Map<String, dynamic>>()
              ?.map(DataRevisionUpdates.fromJson) ??
          []);
  @override
  String toString() =>
      'ActivityUpdateResponse { previousRevision: $previousRevision, succeded: $succeded, failed: $failed }';

  @override
  List<Object> get props => [previousRevision, succeded, failed];
  @override
  bool get stringify => true;
}

class DataRevisionUpdates extends Equatable {
  final String id;
  final int revision;
  const DataRevisionUpdates(this.id, this.revision);
  static DataRevisionUpdates fromJson(Map<String, dynamic> json) =>
      DataRevisionUpdates(json['id'], json['newRevision']);

  @override
  List<Object> get props => [id, revision];
  @override
  bool get stringify => true;
}
