import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:seagull/models/all.dart';

class ChecklistData extends SortableData {
  final Checklist checklist;

  const ChecklistData(this.checklist);

  @override
  List<Object> get props => [checklist];

  @override
  String toRaw() => json.encode({
        'checkItems': List.from(checklist.questions.map((x) => x.toJson())),
        'image': checklist.image,
        'name': checklist.name,
        'fileId': checklist.fileId,
      });

  factory ChecklistData.fromJson(String data) {
    final sortableData = json.decode(data);
    final checklist = Checklist(
      image: sortableData['image'] ?? '',
      fileId: sortableData['fileId'] ?? '',
      icon: sortableData['icon'] ?? '',
      name: sortableData['name'] ?? '',
      questions: sortableData['checkItems'] != null
          ? List<Question>.from(
              (sortableData['checkItems'] as List).mapIndexed(
                (i, x) => Question.fromJson(x, i),
              ),
            )
          : List<Question>.empty(),
    );
    return ChecklistData(checklist);
  }

  @override
  String title(t) => checklist.name;

  @override
  String dataFileId() => checklist.fileId;

  @override
  String dataFilePath() => checklist.icon;

  @override
  bool hasImage() => checklist.fileId.isNotEmpty || checklist.icon.isNotEmpty;
}
