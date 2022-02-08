part of 'sortable.dart';

abstract class SortableData extends Equatable {
  const SortableData();

  String toRaw();

  String title(Translated t);

  String dataFileId();

  String dataFilePath();

  bool hasImage();
}

class RawSortableData extends SortableData {
  final String data;

  const RawSortableData(this.data);

  @override
  String toRaw() => data;

  @override
  List<Object> get props => [data];

  static RawSortableData fromJson(String data) => RawSortableData(data);

  @override
  String title(t) => '';

  @override
  String dataFileId() => '';

  @override
  String dataFilePath() => '';

  @override
  bool hasImage() => false;
}

class ImageArchiveData extends SortableData {
  final String name, fileId, icon, file;
  final bool upload, myPhotos;
  final List<String> tags;

  const ImageArchiveData({
    this.name = '',
    this.file = '',
    this.fileId = '',
    this.icon = '',
    this.upload = false,
    this.myPhotos = false,
    this.tags = const [],
  }) : super();

  @override
  String toRaw() => json.encode({
        if (name.isNotEmpty) 'name': name,
        if (fileId.isNotEmpty) 'fileId': fileId,
        if (icon.isNotEmpty) 'icon': icon,
        if (file.isNotEmpty) 'file': file,
        if (upload) 'upload': upload,
        if (myPhotos) 'myPhotos': myPhotos,
        if (tags.isNotEmpty) 'tags': tags,
      });

  @override
  List<Object?> get props => [name, fileId, icon, file];

  factory ImageArchiveData.fromJson(String data) {
    final sortableData = json.decode(data);
    return ImageArchiveData(
      name: sortableData['name'] ?? '',
      fileId: sortableData['fileId'] ?? '',
      icon: sortableData['icon'] ?? '',
      file: sortableData['file'] ?? '',
      upload: sortableData['upload'] ?? false,
      myPhotos: sortableData['myPhotos'] ?? false,
      tags: sortableData['tags'] ?? [],
    );
  }

  @override
  String title(Translated t) => myPhotos
      ? t.myPhotos
      : upload
          ? t.mobilePictures
          : name;

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;

  bool isInPhotoCalendar() => tags.contains('photoCalendar');
}

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
  String title(t) => name;

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;
}

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
              sortableData['checkItems'].map(
                (x) => Question.fromJson(x),
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

abstract class BasicTimerData extends SortableData {}

class BasicTimerDataItem extends BasicTimerData {
  final String fileId, icon, basicTimerTitle;
  final int duration;

  BasicTimerDataItem._({
    required this.basicTimerTitle,
    required this.icon,
    required this.fileId,
    this.duration = 0,
  });

  factory BasicTimerDataItem.fromJson(String data) {
    final sortableData = json.decode(data);
    return BasicTimerDataItem._(
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
  List<Object> get props => [title, icon, fileId];

  @override
  String title(t) => basicTimerTitle;

  @override
  String toRaw() => json.encode({
        'name': basicTimerTitle,
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

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  List<Object> get props => [name, icon, fileId];

  @override
  String title(t) => name;

  @override
  String toRaw() => json.encode({
        'name': name,
        'icon': icon,
        'fileId': fileId,
      });

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;
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
    this.fileId = '',
    this.icon = '',
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
      reminders: sortableData['reminders'] ?? '',
      activityTitle: sortableData['title'] ?? '',
      name: sortableData['name'] ?? '',
    );
  }

  @visibleForTesting
  factory BasicActivityDataItem.createNew({
    required String title,
    Duration startTime = Duration.zero,
    Duration duration = Duration.zero,
  }) =>
      BasicActivityDataItem._(
        activityTitle: title,
        startTime: startTime.inMilliseconds,
        duration: duration.inMilliseconds,
      );

  TimeOfDay? get startTimeOfDay =>
      startTime == 0 && duration <= 0 ? null : startTime.toTimeOfDay();
  TimeOfDay? get endTimeOfDay =>
      duration == 0 ? null : (startTime + duration).toTimeOfDay();

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;

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
  String title(t) => activityTitle.isEmpty ? name : activityTitle;

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
    required String timezone,
    required DateTime day,
  }) {
    return Activity.createNew(
      title: activityTitle,
      startTime: day,
      timezone: timezone,
      alarmType: alarmType,
      category: category,
      duration: Duration(milliseconds: duration),
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

  TimeInterval toTimeInterval({required DateTime startDate}) => TimeInterval(
        startDate: startDate.onlyDays(),
        startTime: startTimeOfDay,
        endTime: endTimeOfDay,
      );
}

class BasicActivityDataFolder extends BasicActivityData {
  final String name, icon, fileId;

  BasicActivityDataFolder._({
    required this.name,
    required this.icon,
    required this.fileId,
  });

  factory BasicActivityDataFolder.fromJson(String data) {
    final sortableData = json.decode(data);
    return BasicActivityDataFolder._(
      name: sortableData['name'] ?? '',
      icon: sortableData['icon'] ?? '',
      fileId: sortableData['fileId'] ?? '',
    );
  }

  @visibleForTesting
  factory BasicActivityDataFolder.createNew({
    String? name,
    String? icon,
    String? fileId,
  }) =>
      BasicActivityDataFolder._(
        name: name ?? '',
        icon: icon ?? '',
        fileId: fileId ?? '',
      );

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;

  @override
  List<Object> get props => [name, icon, fileId];

  @override
  String title(t) => name;

  @override
  String toRaw() => json.encode({
        'name': name,
        'icon': icon,
        'fileId': fileId,
      });
}
