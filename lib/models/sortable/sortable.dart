import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:uuid/uuid.dart';

part 'db_sortable.dart';
part 'sortable_data.dart';

class SortableType {
  static const String imageArchive = 'imagearchive',
      checklist = 'checklist',
      basetimer = 'basetimer',
      baseactivity = 'baseactivity',
      note = 'note';
}

class Sortable<T extends SortableData> extends DataModel {
  final String type, groupId, sortOrder;
  final bool deleted, isGroup, visible;

  final T data;

  const Sortable._({
    @required String id,
    @required this.type,
    @required this.data,
    @required this.groupId,
    @required this.sortOrder,
    @required this.deleted,
    @required this.isGroup,
    @required this.visible,
  })  : assert(data != null),
        super(id);

  static Sortable<T> createNew<T extends SortableData>({
    @required T data,
    String groupId,
    String sortOrder = '',
    bool deleted = false,
    bool isGroup = false,
    bool visible = true,
  }) {
    return Sortable<T>._(
        id: Uuid().v4(),
        type: _getTypeString<T>(),
        data: data,
        groupId: groupId,
        sortOrder: sortOrder,
        deleted: deleted,
        isGroup: isGroup,
        visible: visible);
  }

  static String _getTypeString<T extends SortableData>() {
    if (T == ImageArchiveData) return SortableType.imageArchive;
    if (T == NoteData) return SortableType.note;
    return '';
  }

  @override
  List<Object> get props =>
      [id, type, data, groupId, sortOrder, deleted, isGroup, visible];

  @override
  bool get stringify => true;

  @override
  DbModel<DataModel> wrapWithDbModel({int revision = 0, int dirty = 0}) =>
      DbSortable._(sortable: this, revision: revision, dirty: dirty);
}