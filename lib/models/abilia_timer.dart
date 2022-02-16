import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';
import 'package:uuid/uuid.dart';

class AbiliaTimer extends Equatable {
  final String id;
  final String title;
  final String fileId;
  final bool paused;
  final DateTime startTime;
  final Duration duration;
  final Duration pausedAt;

  const AbiliaTimer({
    required this.id,
    this.title = '',
    this.fileId = '',
    this.paused = false,
    required this.startTime,
    required this.duration,
    this.pausedAt = Duration.zero,
  });

  factory AbiliaTimer.createNew({
    String? title = '',
    String? fileId = '',
    required DateTime startTime,
    required Duration duration,
  }) =>
      AbiliaTimer(
        id: const Uuid().v4(),
        title: title ?? '',
        fileId: fileId ?? '',
        startTime: startTime,
        duration: duration,
      );

  DateTime get endTime => startTime.add(duration);

  bool get hasImage => fileId.isNotEmpty;
  bool get hasTitle => title.isNotEmpty;
  AbiliaFile get imageFile => AbiliaFile.from(id: fileId);

  Map<String, dynamic> toMapForDb() => {
        'id': id,
        'title': title,
        'file_id': fileId,
        'paused': paused ? 1 : 0,
        'start_time': startTime.millisecondsSinceEpoch,
        'duration': duration.inMilliseconds,
        'paused_at': pausedAt.inMilliseconds,
      };

  TimerOccasion toOccasion(DateTime now) {
    if (now.isAfter(endTime)) return TimerOccasion(this, Occasion.past);
    return TimerOccasion(this, Occasion.current);
  }

  static AbiliaTimer fromDbMap(Map<String, dynamic> dbRow) => AbiliaTimer(
        id: dbRow['id'],
        title: dbRow['title'],
        fileId: dbRow['file_id'],
        paused: dbRow['full_day'] == 1,
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
