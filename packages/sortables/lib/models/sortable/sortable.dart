import 'package:flutter/material.dart';
import 'package:repository_base/repository_base.dart';
import 'package:sortables/sortables.dart';
import 'package:utils/utils.dart';
import 'package:uuid/uuid.dart';

part 'db_sortable.dart';

class SortableType {
  static const String imageArchive = 'imagearchive',
      checklist = 'checklist',
      basicTimer = 'basetimer',
      basicActivity = 'baseactivity',
      note = 'note';
  static const supportedTypes = [
    imageArchive,
    checklist,
    basicTimer,
    basicActivity,
    note
  ];
}

class Sortable<T extends SortableData> extends DataModel {
  final String type, groupId, sortOrder;
  final bool isGroup, visible, fixed;

  final T data;

  const Sortable._({
    required super.id,
    required super.deleted,
    required this.type,
    required this.data,
    required this.groupId,
    required this.sortOrder,
    required this.isGroup,
    required this.visible,
    required this.fixed,
  });

  static Sortable<T> createNew<T extends SortableData>({
    required T data,
    String groupId = '',
    String sortOrder = startSortOrder,
    bool deleted = false,
    bool isGroup = false,
    bool visible = true,
    bool fixed = false,
  }) {
    assert(sortOrder.isNotEmpty);
    return Sortable<T>._(
      id: const Uuid().v4(),
      type: _getTypeString(data.runtimeType),
      data: data,
      groupId: groupId,
      sortOrder: sortOrder,
      deleted: deleted,
      isGroup: isGroup,
      visible: visible,
      fixed: fixed,
    );
  }

  static String _getTypeString(Type t) {
    switch (t) {
      case ImageArchiveData:
        return SortableType.imageArchive;
      case NoteData:
        return SortableType.note;
      case ChecklistData:
        return SortableType.checklist;
      case BasicActivityData:
      case BasicActivityDataItem:
      case BasicActivityDataFolder:
        return SortableType.basicActivity;
      case BasicTimerData:
      case BasicTimerDataItem:
      case BasicTimerDataFolder:
        return SortableType.basicTimer;
    }
    throw 'no mapping from Type $t and type string';
  }

  @override
  List<Object> get props => [
        id,
        type,
        data,
        groupId,
        sortOrder,
        deleted,
        isGroup,
        visible,
        fixed,
      ];

  @override
  bool get stringify => true;

  @override
  DbModel<DataModel> wrapWithDbModel({int revision = 0, int dirty = 0}) =>
      DbSortable._(sortable: this, revision: revision, dirty: dirty);

  Sortable<T> copyWith({
    T? data,
    String? groupId,
    String? sortOrder,
    bool? deleted,
  }) =>
      Sortable._(
        id: id,
        type: type,
        data: data ?? this.data,
        groupId: groupId ?? this.groupId,
        sortOrder: sortOrder ?? this.sortOrder,
        deleted: deleted ?? this.deleted,
        isGroup: isGroup,
        visible: visible,
        fixed: fixed,
      );
}
