import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:sortables/models/sortable/data/sortable_data.dart';

abstract class BasicTimerData extends SortableData {}

class BasicTimerDataItem extends BasicTimerData {
  final String fileId, icon, basicTimerTitle;
  final int duration;

  BasicTimerDataItem({
    required this.basicTimerTitle,
    required this.icon,
    required this.fileId,
    this.duration = 0,
  });

  factory BasicTimerDataItem.createNew() => BasicTimerDataItem(
        basicTimerTitle: '',
        duration: 0,
        icon: '',
        fileId: '',
      );

  factory BasicTimerDataItem.fromJson(String data) {
    final sortableData = json.decode(data);
    return BasicTimerDataItem(
      basicTimerTitle: sortableData['title'] ?? '',
      icon: sortableData['icon'] ?? '',
      fileId: sortableData['fileId'] ?? '',
      duration: sortableData['duration'] ?? 0,
    );
  }

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  List<Object> get props => [basicTimerTitle, duration, icon, fileId];

  @override
  String title() => basicTimerTitle;

  @override
  String toRaw() => json.encode({
        'title': basicTimerTitle,
        'duration': duration,
        'icon': icon,
        'fileId': fileId,
      });

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;
}

class BasicTimerDataFolder extends BasicTimerData {
  final String name, icon, fileId;
  BasicTimerDataFolder._({
    required this.name,
    required this.icon,
    required this.fileId,
  });

  factory BasicTimerDataFolder.fromJson(String data) {
    final sortableData = json.decode(data);
    return BasicTimerDataFolder._(
      name: sortableData['name'] ?? '',
      icon: sortableData['icon'] ?? '',
      fileId: sortableData['fileId'] ?? '',
    );
  }

  @visibleForTesting
  factory BasicTimerDataFolder.createNew({
    String? name,
    String? icon,
    String? fileId,
  }) =>
      BasicTimerDataFolder._(
        name: name ?? '',
        icon: icon ?? '',
        fileId: fileId ?? '',
      );

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  List<Object> get props => [name, icon, fileId];

  @override
  String title() => name;

  @override
  String toRaw() => json.encode({
        'name': name,
        'icon': icon,
        'fileId': fileId,
      });

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;
}
