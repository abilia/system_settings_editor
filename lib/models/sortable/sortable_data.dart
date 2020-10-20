part of 'sortable.dart';

abstract class SortableData extends Equatable {
  const SortableData();
  String toRaw();
  String title();
  String folderFileId();
  String folderFilePath();
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
  String title() => '';

  @override
  String folderFileId() => '';

  @override
  String folderFilePath() => '';
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
  String title() => name;

  @override
  String folderFileId() => fileId;

  @override
  String folderFilePath() => icon;
}

class NoteData extends SortableData {
  final String name, text, icon, fileId;

  NoteData({this.name, this.text, this.icon, this.fileId});

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
  String title() => name;

  @override
  String folderFileId() => fileId;

  @override
  String folderFilePath() => icon;
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
  String title() => checklist.name;

  @override
  String folderFileId() => checklist.fileId;

  @override
  String folderFilePath() => checklist.icon;
}

abstract class BasicActivityData extends SortableData {}

class BasicActivityDataItem extends BasicActivityData {
  final int alarmType, category, duration, startTime;
  final bool checkable, fullDay, removeAfter, secret;
  final String fileId, icon, info, reminders, activityTitle, name;

  BasicActivityDataItem._({
    this.alarmType = 0,
    this.category = 0,
    this.duration = 0,
    this.startTime = 0,
    this.checkable = false,
    this.fullDay = false,
    this.removeAfter = false,
    this.secret = false,
    this.fileId,
    this.icon,
    this.info = '',
    this.reminders = '',
    this.activityTitle = '',
    this.name = '',
  });

  factory BasicActivityDataItem.fromJson(String data) {
    final sortableData = json.decode(data);
    return BasicActivityDataItem._(
      alarmType: sortableData['alarmType'] ?? 0,
      category: sortableData['category'] ?? 0,
      duration: sortableData['duration'] ?? 0,
      startTime: sortableData['startTime'] ?? 0,
      checkable: sortableData['checkable'] ?? false,
      fullDay: sortableData['fullDay'] ?? false,
      removeAfter: sortableData['removeAfter'] ?? false,
      secret: sortableData['secret'] ?? false,
      fileId: sortableData['fileId'] ?? '',
      icon: sortableData['icon'] ?? '',
      info: sortableData['info'] ?? '',
      reminders: sortableData['reminders'],
      activityTitle: sortableData['title'],
      name: sortableData['name'],
    );
  }

  factory BasicActivityDataItem.createNew({
    @required String title,
  }) {
    return BasicActivityDataItem._(activityTitle: title);
  }

  bool get hasImage =>
      (fileId?.isNotEmpty ?? false) || (icon?.isNotEmpty ?? false);

  @override
  String folderFileId() => fileId;

  @override
  String folderFilePath() => icon;

  @override
  List<Object> get props => [
        alarmType,
        category,
        duration,
        startTime,
        checkable,
        fullDay,
        removeAfter,
        secret,
        fileId,
        icon,
        info,
        reminders,
        activityTitle,
        name,
      ];

  @override
  String title() => activityTitle ?? name;

  @override
  String toRaw() => json.encode({
        'alarmType': alarmType,
        'category': category,
        'duration': duration,
        'startTime': startTime,
        'checkable': checkable,
        'fullDay': fullDay,
        'removeAfter': removeAfter,
        'secret': secret,
        'fileId': fileId,
        'icon': icon,
        'info': info,
        'reminders': reminders,
        'title': activityTitle,
        'name': name,
      });

  Activity toActivity({
    @required String timezone,
    @required DateTime day,
  }) {
    return Activity.createNew(
      title: activityTitle,
      startTime: day,
      timezone: timezone,
      alarmType: alarmType,
      category: category,
      duration:
          duration == null ? 0.seconds() : Duration(milliseconds: duration),
      checkable: checkable,
      fullDay: fullDay,
      removeAfter: removeAfter,
      secret: secret,
      fileId: fileId,
      icon: icon,
      infoItem: InfoItem.fromJsonString(info),
      reminderBefore: DbActivity.parseReminders(reminders),
    );
  }

  TimeInterval toTimeInterval({DateTime startDate}) {
    final start = startDate.onlyDays().add(startTime.milliseconds());
    final end = start.add(duration.milliseconds());
    return TimeInterval(
      startDate: startDate,
      startTime: TimeOfDay.fromDateTime(start),
      endTime: (duration == null || duration == 0)
          ? null
          : TimeOfDay.fromDateTime(end),
    );
  }
}

class BasicActivityDataFolder extends BasicActivityData {
  final String name, icon, fileId;

  BasicActivityDataFolder._({
    @required this.name,
    @required this.icon,
    @required this.fileId,
  });

  factory BasicActivityDataFolder.fromJson(String data) {
    final sortableData = json.decode(data);
    return BasicActivityDataFolder._(
      name: sortableData['name'] ?? '',
      icon: sortableData['icon'] ?? '',
      fileId: sortableData['fileId'] ?? '',
    );
  }

  @override
  String folderFileId() => fileId;

  @override
  String folderFilePath() => icon;

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
}
