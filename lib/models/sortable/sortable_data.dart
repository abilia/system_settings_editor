part of 'sortable.dart';

abstract class SortableData extends Equatable {
  const SortableData();
  String toRaw();
  String title();
}

class RawSortableData extends SortableData {
  final String data;

  RawSortableData(this.data);

  @override
  String toRaw() => data;

  @override
  List<Object> get props => [data];

  static RawSortableData fromJson(String data) => RawSortableData(data);

  @override
  String title() {
    return '';
  }
}

class ImageArchiveData extends SortableData {
  final String name, fileId, icon, file;
  final bool upload;

  const ImageArchiveData({
    this.name,
    this.fileId,
    this.icon,
    this.file,
    this.upload,
  }) : super();

  @override
  String toRaw() => json.encode({
        if (name != null) 'name': name,
        if (fileId != null) 'fileId': fileId,
        if (icon != null) 'icon': icon,
        if (file != null) 'file': file,
        if (upload != null) 'upload': upload,
      });

  @override
  List<Object> get props => [name, fileId, icon, file];

  factory ImageArchiveData.fromJson(String data) {
    final sortableData = json.decode(data);
    return ImageArchiveData(
        name: sortableData['name'],
        fileId: sortableData['fileId'],
        icon: sortableData['icon'],
        file: sortableData['file'],
        upload: sortableData['upload']);
  }

  @override
  String title() {
    return name;
  }
}

class NoteData extends SortableData {
  final String name, text, icon, fileId;

  NoteData({this.name, this.text, this.icon, this.fileId});

  @override
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
      name: sortableData['name'],
      text: sortableData['text'],
      icon: sortableData['icon'],
      fileId: sortableData['fileId'],
    );
  }

  @override
  String title() {
    return name;
  }
}

class ChecklistData extends SortableData {
  final Checklist checklist;

  ChecklistData(this.checklist);

  @override
  List<Object> get props => [checklist];

  @override
  String toRaw() => json.encode({
        'checkItems': checklist.questions != null
            ? List.from(checklist.questions.map((x) => x.toJson()))
            : List.empty(),
        'image': checklist.image,
        'name': checklist.name,
        'fileId': checklist.fileId,
      });

  factory ChecklistData.fromJson(String data) {
    final sortableData = json.decode(data);
    final checklist = Checklist(
      image: sortableData['image'],
      fileId: sortableData['fileId'],
      icon: sortableData['icon'],
      name: sortableData['name'],
      questions: sortableData['checkItems'] != null
          ? List<Question>.from(
              sortableData['checkItems'].map(
                (x) => Question.fromJson(x),
              ),
            )
          : List<Question>.empty(),
    );
    return ChecklistData(checklist);
  }

  @override
  String title() {
    return checklist.name;
  }
}
