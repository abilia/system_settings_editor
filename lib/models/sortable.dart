import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

class Sortable extends Equatable {
  final String id, type, data, groupId, sortOrder;
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
    @required this.id,
    @required this.type,
    @required this.data,
    @required this.groupId,
    @required this.sortOrder,
    @required this.deleted,
    @required this.isGroup,
    @required this.isVisible,
  }) : assert(id != null);

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
}

class SortableType {
  static const String imageArchive = 'imagearchive', checklist = 'checklist';
}

class DbSortable extends Equatable {
  final Sortable sortable;
  final int revision, dirty;

  const DbSortable._(
      {@required this.sortable, @required this.revision, @required this.dirty});

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
  List<Object> get props => [sortable, revision, dirty];

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
}

class SortableData {
  final String name, fileId, icon, file;

  SortableData({
    this.name,
    this.fileId,
    this.icon,
    this.file,
  });
}
