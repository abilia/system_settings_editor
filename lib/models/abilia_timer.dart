import 'package:equatable/equatable.dart';

class AbiliaTimer extends Equatable {
  final String id;
  final String title;
  final String? fileId;
  final DateTime startTime;
  final Duration duration;

  const AbiliaTimer({
    required this.id,
    required this.title,
    this.fileId,
    required this.startTime,
    required this.duration,
  });

  Map<String, dynamic> toMapForDb() => {
        'id': id,
        'title': title,
        'file_id': fileId,
        'start_time': startTime.millisecondsSinceEpoch,
        'duration': duration.inMilliseconds,
      };

  static AbiliaTimer fromDbMap(Map<String, dynamic> dbRow) => AbiliaTimer(
        id: dbRow['id'],
        title: dbRow['title'],
        fileId: dbRow['file_id'],
        startTime: DateTime.fromMillisecondsSinceEpoch(dbRow['start_time']),
        duration: Duration(milliseconds: dbRow['duration'] ?? 0),
      );

  @override
  List<Object?> get props => [id, title, fileId, startTime, duration];
}
