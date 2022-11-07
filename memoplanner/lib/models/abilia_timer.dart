import 'package:uuid/uuid.dart';
import 'package:memoplanner/models/all.dart';

class AbiliaTimer extends Event {
  @override
  final String id;
  @override
  final String title;
  final String fileId;
  final bool paused;
  final DateTime startTime;
  final Duration duration;
  final Duration pausedAt;

  const AbiliaTimer({
    required this.id,
    required this.startTime,
    required this.duration,
    this.title = '',
    this.fileId = '',
    this.paused = false,
    this.pausedAt = Duration.zero,
  });

  factory AbiliaTimer.createNew({
    required DateTime startTime,
    required Duration duration,
    String? title = '',
    String? fileId = '',
  }) =>
      AbiliaTimer(
        id: const Uuid().v4(),
        title: title ?? '',
        fileId: fileId ?? '',
        startTime: startTime,
        duration: duration,
      );

  @override
  DateTime get start => startTime;
  @override
  DateTime get end => startTime.add(duration);
  @override
  bool get hasImage => fileId.isNotEmpty;

  bool get hasTitle => title.isNotEmpty;
  @override
  AbiliaFile get image => AbiliaFile.from(id: fileId);
  @override
  int get category => Category.right;

  Map<String, dynamic> toMapForDb() => {
        'id': id,
        'title': title,
        'file_id': fileId,
        'paused': paused ? 1 : 0,
        'start_time': startTime.millisecondsSinceEpoch,
        'duration': duration.inMilliseconds,
        'paused_at': pausedAt.inMilliseconds,
      };

  @override
  TimerOccasion toOccasion(DateTime now) {
    if (now.isAfter(end)) return TimerOccasion(this, Occasion.past);
    return TimerOccasion(this, Occasion.current);
  }

  AbiliaTimer pause(DateTime pauseTime) => AbiliaTimer(
        id: id,
        startTime: startTime,
        duration: duration,
        paused: true,
        pausedAt: end.difference(pauseTime),
        title: title,
        fileId: fileId,
      );

  AbiliaTimer resume(DateTime resumeTime) {
    if (!paused) return this;
    return AbiliaTimer(
      id: id,
      startTime: resumeTime.subtract(duration - pausedAt),
      duration: duration,
      paused: false,
      pausedAt: Duration.zero,
      title: title,
      fileId: fileId,
    );
  }

  static AbiliaTimer fromDbMap(Map<String, dynamic> dbRow) => AbiliaTimer(
        id: dbRow['id'],
        title: dbRow['title'],
        fileId: dbRow['file_id'],
        paused: dbRow['paused'] == 1,
        startTime: DateTime.fromMillisecondsSinceEpoch(dbRow['start_time']),
        duration: Duration(milliseconds: dbRow['duration'] ?? 0),
        pausedAt: Duration(milliseconds: dbRow['paused_at'] ?? 0),
      );

  @override
  List<Object?> get props => [
        id,
        title,
        fileId,
        paused,
        startTime,
        duration,
        pausedAt,
      ];
}
