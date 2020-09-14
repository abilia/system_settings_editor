import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:uuid/uuid.dart';

part 'db_generic.dart';
part 'generic_data.dart';

class GenericType {
  static const String memoPlannerSettings = 'memoPlannerSettings';
}

class Generic<T extends GenericData> extends DataModel {
  final String type, identifier;
  final bool deleted;

  final T data;

  const Generic._({
    @required String id,
    @required this.type,
    @required this.data,
    @required this.identifier,
    @required this.deleted,
  })  : assert(data != null),
        super(id);

  static Generic<T> createNew<T extends GenericData>({
    @required T data,
    @required String type,
    @required String identifier,
    bool deleted = false,
  }) {
    return Generic<T>._(
      id: Uuid().v4(),
      type: _getTypeString<T>(),
      data: data,
      deleted: deleted,
      identifier: identifier,
    );
  }

  static String _getTypeString<T extends GenericData>() {
    if (T == MemoplannerSettingData) return GenericType.memoPlannerSettings;
    return '';
  }

  @override
  List<Object> get props => [id, type, identifier, data, deleted];

  @override
  bool get stringify => true;

  @override
  DbModel<DataModel> wrapWithDbModel({int revision = 0, int dirty = 0}) =>
      DbGeneric._(generic: this, revision: revision, dirty: dirty);
}
