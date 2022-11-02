part of 'sortable.dart';

class DbSortable extends DbModel<Sortable> {
  Sortable get sortable => model;
  const DbSortable._(
      {required Sortable sortable, required int revision, required int dirty})
      : super(model: sortable, revision: revision, dirty: dirty);

  @override
  DbSortable copyWith({
    int? revision,
    int? dirty,
  }) {
    return DbSortable._(
      sortable: sortable,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
    );
  }

  @visibleForTesting
  static Sortable toType(
    String id,
    String type,
    String data,
    String groupId,
    String sortOrder,
    bool deleted,
    bool isGroup,
    bool visible,
    bool fixed,
  ) {
    switch (type) {
      case SortableType.imageArchive:
        return Sortable<ImageArchiveData>._(
          id: id,
          type: type,
          data: ImageArchiveData.fromJson(data),
          groupId: groupId,
          sortOrder: sortOrder,
          deleted: deleted,
          isGroup: isGroup,
          visible: visible,
          fixed: fixed,
        );
      case SortableType.note:
        return Sortable<NoteData>._(
          id: id,
          type: type,
          data: NoteData.fromJson(data),
          groupId: groupId,
          sortOrder: sortOrder,
          deleted: deleted,
          isGroup: isGroup,
          visible: visible,
          fixed: fixed,
        );
      case SortableType.checklist:
        return Sortable<ChecklistData>._(
          id: id,
          type: type,
          data: ChecklistData.fromJson(data),
          groupId: groupId,
          sortOrder: sortOrder,
          deleted: deleted,
          isGroup: isGroup,
          visible: visible,
          fixed: fixed,
        );
      case SortableType.basicTimer:
        return isGroup
            ? Sortable<BasicTimerDataFolder>._(
                id: id,
                type: type,
                data: BasicTimerDataFolder.fromJson(data),
                groupId: groupId,
                sortOrder: sortOrder,
                deleted: deleted,
                isGroup: isGroup,
                visible: visible,
                fixed: fixed,
              )
            : Sortable<BasicTimerDataItem>._(
                id: id,
                type: type,
                data: BasicTimerDataItem.fromJson(data),
                groupId: groupId,
                sortOrder: sortOrder,
                deleted: deleted,
                isGroup: isGroup,
                visible: visible,
                fixed: fixed,
              );
      case SortableType.basicActivity:
        return isGroup
            ? Sortable<BasicActivityDataFolder>._(
                id: id,
                type: type,
                data: BasicActivityDataFolder.fromJson(data),
                groupId: groupId,
                sortOrder: sortOrder,
                deleted: deleted,
                isGroup: isGroup,
                visible: visible,
                fixed: fixed,
              )
            : Sortable<BasicActivityDataItem>._(
                id: id,
                type: type,
                data: BasicActivityDataItem.fromJson(data),
                groupId: groupId,
                sortOrder: sortOrder,
                deleted: deleted,
                isGroup: isGroup,
                visible: visible,
                fixed: fixed,
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
          fixed: fixed,
        );
    }
  }

  static DbSortable fromJson(Map<String, dynamic> json) => DbSortable._(
        sortable: Sortable<RawSortableData>._(
          id: json['id'],
          type: json['type'],
          data: RawSortableData(json['data'] ?? ''),
          groupId: json['groupId'] ?? '',
          sortOrder: json['sortOrder'] ?? '',
          deleted: json['deleted'] ?? false,
          isGroup: json['group'] ?? false,
          visible: json['visible'] ?? true,
          fixed: json['fixed'] ?? false,
        ),
        revision: json['revision'],
        dirty: 0,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': sortable.id,
        'type': sortable.type.nullOnEmpty(),
        'data': sortable.data.toRaw().nullOnEmpty(),
        'groupId': sortable.groupId.nullOnEmpty(),
        'sortOrder': sortable.sortOrder.nullOnEmpty(),
        'deleted': sortable.deleted,
        'group': sortable.isGroup,
        'visible': sortable.visible,
        'revision': revision,
        'fixed': sortable.fixed,
      };

  static DbSortable fromDbMap(Map<String, dynamic> dbRow) => DbSortable._(
        sortable: DbSortable.toType(
          dbRow['id'],
          dbRow['type'],
          dbRow['data'],
          dbRow['group_id'] ?? '',
          dbRow['sort_order'],
          dbRow['deleted'] == 1,
          dbRow['is_group'] == 1,
          dbRow['visible'] == 1,
          dbRow['fixed'] == 1,
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
        'fixed': sortable.fixed ? 1 : 0,
        'revision': revision,
        'dirty': dirty,
      };

  @override
  List<Object> get props => [sortable, revision, dirty];
  @override
  String toString() =>
      'DbSortable: { revision: $revision, dirty: $dirty $sortable }';
}
