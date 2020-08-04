part of 'sortable.dart';

class DbSortable extends DbModel<Sortable> {
  Sortable get sortable => model;
  const DbSortable._(
      {@required Sortable sortable,
      @required int revision,
      @required int dirty})
      : super(model: sortable, revision: revision, dirty: dirty);

  @override
  DbSortable copyWith({int revision, int dirty}) {
    return DbSortable._(
      sortable: sortable,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
    );
  }

  static Sortable _toType(
    String id,
    String type,
    String data,
    String groupId,
    String sortOrder,
    bool deleted,
    bool isGroup,
    bool visible,
  ) {
    switch (type) {
      case SortableType.imageArchive:
        return Sortable<ImageArchiveData>._(
          id: id,
          type: SortableType.imageArchive,
          data: ImageArchiveData.fromJson(data),
          groupId: groupId,
          sortOrder: sortOrder,
          deleted: deleted,
          isGroup: isGroup,
          visible: visible,
        );
      case SortableType.note:
        return Sortable<NoteData>._(
          id: id,
          type: SortableType.note,
          data: NoteData.fromJson(data),
          groupId: groupId,
          sortOrder: sortOrder,
          deleted: deleted,
          isGroup: isGroup,
          visible: visible,
        );
      default:
        return Sortable<RawSortableData>._(
          id: id,
          type: type,
          data: RawSortableData(data),
          groupId: groupId,
          sortOrder: sortOrder,
          deleted: deleted,
          isGroup: isGroup,
          visible: visible,
        );
    }
  }

  static DbSortable fromJson(Map<String, dynamic> json) => DbSortable._(
        sortable: DbSortable._toType(
          json['id'],
          json['type'],
          json['data'],
          json['groupId'],
          json['sortOrder'],
          json['deleted'],
          json['group'],
          json['visible'],
        ),
        revision: json['revision'],
        dirty: 0,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': sortable.id,
        'type': sortable.type,
        'data': sortable.data.toRaw(),
        'groupId': sortable.groupId,
        'sortOrder': sortable.sortOrder,
        'deleted': sortable.deleted,
        'group': sortable.isGroup,
        'visible': sortable.visible,
        'revision': revision,
      };

  static DbSortable fromDbMap(Map<String, dynamic> dbRow) => DbSortable._(
        sortable: DbSortable._toType(
          dbRow['id'],
          dbRow['type'],
          dbRow['data'],
          dbRow['group_id'],
          dbRow['sort_order'],
          dbRow['deleted'] == 1,
          dbRow['is_group'] == 1,
          dbRow['visible'] == 1,
        ),
        revision: dbRow['revision'],
        dirty: dbRow['dirty'],
      );

  @override
  Map<String, dynamic> toMapForDb() => {
        'id': sortable.id,
        'type': sortable.type,
        'data': sortable.data.toRaw(),
        'group_id': sortable.groupId,
        'sort_order': sortable.sortOrder,
        'deleted': sortable.deleted ? 1 : 0,
        'is_group': sortable.isGroup ? 1 : 0,
        'visible': sortable.visible ? 1 : 0,
        'revision': revision,
        'dirty': dirty,
      };

  @override
  List<Object> get props => [sortable, revision, dirty];
  @override
  String toString() =>
      'DbSortable: { revision: $revision, dirty: $dirty $sortable }';
}
