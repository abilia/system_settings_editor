import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:uuid/uuid.dart';

class Sortable extends DataModel {
  final String type, data, groupId, sortOrder;
  final bool deleted, isGroup, isVisible;

  SortableData get sortableData {
    final sortableData = json.decode(data);
    return type == SortableType.imageArchive
        ? SortableData(
            name: sortableData['name'],
            fileId: sortableData['fileId'],
            icon: sortableData['icon'],
            file: sortableData['file'],
          )
        : SortableData();
  }

  const Sortable._({
    @required String id,
    @required this.type,
    @required this.data,
    @required this.groupId,
    @required this.sortOrder,
    @required this.deleted,
    @required this.isGroup,
    @required this.isVisible,
  }) : super(id);

  static Sortable createNew({
    String type,
    String data,
    String groupId,
    String sortOrder = '',
    bool deleted = false,
    bool isGroup = false,
    bool isVisible = true,
  }) {
    final id = Uuid().v4();
    return Sortable._(
      id: id,
      type: type,
      data: data,
      groupId: groupId,
      sortOrder: sortOrder,
      deleted: deleted,
      isGroup: isGroup,
      isVisible: isVisible,
    );
  }

  @override
  List<Object> get props =>
      [id, type, data, groupId, sortOrder, deleted, isGroup, isVisible];

  @override
  String toString() => 'Sortable: { ${props.join(', ')} }';

  @override
  DbModel<DataModel> wrapWithDbModel({int revision = 0, int dirty = 0}) =>
      DbSortable._(sortable: this, revision: revision, dirty: dirty);
}

class SortableType {
  static const String imageArchive = 'imagearchive', checklist = 'checklist';
}

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

  static DbSortable fromJson(Map<String, dynamic> json) => DbSortable._(
        sortable: Sortable._(
          id: json['id'],
          type: json['type'],
          data: json['data'],
          groupId: json['groupId'],
          sortOrder: json['sortOrder'],
          deleted: json['deleted'],
          isGroup: json['group'],
          isVisible: json['visible'],
        ),
        revision: json['revision'],
        dirty: 0,
      );

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return null;
  }

  static DbSortable fromDbMap(Map<String, dynamic> dbRow) => DbSortable._(
        sortable: Sortable._(
          id: dbRow['id'],
          type: dbRow['type'],
          data: dbRow['data'],
          groupId: dbRow['group_id'],
          sortOrder: dbRow['sort_order'],
          deleted: dbRow['deleted'] == 1,
          isGroup: dbRow['is_group'] == 1,
          isVisible: dbRow['visible'] == 1,
        ),
        revision: dbRow['revision'],
        dirty: dbRow['dirty'],
      );

  Map<String, dynamic> toMapForDb() => {
        'id': sortable.id,
        'type': sortable.type,
        'data': sortable.data,
        'group_id': sortable.groupId,
        'sort_order': sortable.sortOrder,
        'deleted': sortable.deleted ? 1 : 0,
        'is_group': sortable.isGroup ? 1 : 0,
        'visible': sortable.isVisible ? 1 : 0,
        'revision': revision,
        'dirty': dirty,
      };

  @override
  List<Object> get props => [sortable, revision, dirty];
  @override
  String toString() =>
      'DbSortable: { revision: $revision, dirty: $dirty $sortable }';
}

class SortableData {
  final String name, fileId, icon, file;

  SortableData({
    this.name,
    this.fileId,
    this.icon,
    this.file,
  });

  toJson() {
    return {
      'name': name,
      'fileId': fileId,
      'icon': icon,
      'file': file,
    };
  }
}
