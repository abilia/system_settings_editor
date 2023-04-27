import 'dart:convert';

import 'package:sortables/models/sortable/data/sortable_data.dart';


class NoteData extends SortableData {
  final String name, text, icon, fileId;

  const NoteData({
    this.name = '',
    this.text = '',
    this.icon = '',
    this.fileId = '',
  });

  @override
  String toRaw() => json.encode({
        'name': name,
        'text': text,
        'icon': icon,
        'fileId': fileId,
      });

  @override
  List<Object> get props => [name, text, icon, fileId];

  factory NoteData.fromJson(String data) {
    final sortableData = json.decode(data);
    return NoteData(
      name: sortableData['name'] ?? '',
      text: sortableData['text'] ?? '',
      icon: sortableData['icon'] ?? '',
      fileId: sortableData['fileId'] ?? '',
    );
  }

  @override
  String title() => name;

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;
}
