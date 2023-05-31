part of 'generic.dart';

class DbGeneric extends DbModel<Generic> {
  Generic get generic => model;
  const DbGeneric._({
    required Generic generic,
    required int revision,
    required int dirty,
  }) : super(model: generic, revision: revision, dirty: dirty);

  @override
  DbGeneric copyWith({int? revision, int? dirty}) {
    return DbGeneric._(
      generic: generic,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
    );
  }

  static Generic _toType({
    required String id,
    required String type,
    required String identifier,
    required String data,
    required bool deleted,
  }) {
    switch (type) {
      case GenericType.memoPlannerSettings:
        return Generic<GenericSettingData>._(
          id: id,
          type: type,
          data: GenericSettingData.fromJson(data, identifier),
          deleted: deleted,
        );
      default:
        return Generic<RawGenericData>._(
          id: id,
          type: type,
          deleted: deleted,
          data: RawGenericData(data, identifier),
        );
    }
  }

  static DbGeneric fromJson(Map<String, dynamic> json) => DbGeneric._(
        generic: DbGeneric._toType(
          id: json['id'],
          type: json['type'],
          data: json['data'],
          identifier: json['identifier'],
          deleted: json['deleted'] ?? false,
        ),
        revision: json['revision'],
        dirty: 0,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': generic.id,
        'type': generic.type?.nullOnEmpty(),
        'identifier': generic.data.identifier.nullOnEmpty(),
        'data': generic.data.toRaw(),
        'deleted': generic.deleted,
        'revision': revision,
      };

  static DbGeneric fromDbMap(Map<String, dynamic> dbRow) => DbGeneric._(
        generic: DbGeneric._toType(
          id: dbRow['id'],
          type: dbRow['type'],
          identifier: dbRow['identifier'],
          data: dbRow['data'],
          deleted: dbRow['deleted'] == 1,
        ),
        revision: dbRow['revision'],
        dirty: dbRow['dirty'],
      );

  @override
  Map<String, dynamic> toMapForDb() => {
        'id': generic.id,
        'type': generic.type,
        'identifier': generic.data.identifier,
        'data': generic.data.toRaw(),
        'deleted': generic.deleted ? 1 : 0,
        'revision': revision,
        'dirty': dirty,
      };

  @override
  List<Object> get props => [generic, revision, dirty];
  @override
  String toString() =>
      'DbGeneric: { revision: $revision, dirty: $dirty $generic }';
}
