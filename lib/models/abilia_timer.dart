class AbiliaTimer {
  final String id;
  final DateTime startTime;
  final Duration duration;

  AbiliaTimer({
    required this.id,
    required this.startTime,
    required this.duration,
  });

  Map<String, dynamic> toMapForDb() => {
        'id': id,
        'start_time': startTime.millisecondsSinceEpoch,
        'duration': duration.inMilliseconds,
      };

  static AbiliaTimer fromDbMap(Map<String, dynamic> dbRow) => AbiliaTimer(
        id: dbRow['id'],
        startTime: DateTime.fromMillisecondsSinceEpoch(dbRow['start_time']),
        duration: Duration(milliseconds: dbRow['duration'] ?? 0),
      );
}
