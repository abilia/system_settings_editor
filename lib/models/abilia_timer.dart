import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class AbiliaTimer extends Equatable implements Event {
  final String id;
  final String title;
  final String fileId;
  final bool paused;
  final DateTime startTime;
  final Duration duration;
  final Duration pausedAt;

  const AbiliaTimer({
    required this.id,
    required this.title,
    this.fileId = '',
    this.paused = false,
    required this.startTime,
    required this.duration,
    this.pausedAt = Duration.zero,
  });

  DateTime get endTime => startTime.add(duration);
  @override
  DateTime startClock(DateTime day) => startTime;
  @override
  DateTime endClock(DateTime day) => endTime;
  @override
  final int category = Category.right;

  Map<String, dynamic> toMapForDb() => {
        'id': id,
        'title': title,
        'file_id': fileId,
        'paused': paused ? 1 : 0,
        'start_time': startTime.millisecondsSinceEpoch,
        'duration': duration.inMilliseconds,
        'paused_at': pausedAt.inMilliseconds,
      };

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
