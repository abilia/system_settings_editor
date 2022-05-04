class Calendar {
  final String id, type;
  final int owner;
  final bool main;

  const Calendar._(
    this.id,
    this.type,
    this.owner,
    this.main,
  );

  factory Calendar.fromJson(Map<String, dynamic> json) => Calendar._(
        json['id'],
        json['type'],
        json['owner'],
        json['main'],
      );

  factory Calendar.fromDbMap(Map<String, dynamic> dbMap) => Calendar._(
        dbMap['id'],
        dbMap['type'],
        dbMap['owner'],
        dbMap['main'] == 1,
      );
  Map<String, dynamic> toMapForDb() => {
        'id': id,
        'type': type,
        'owner': owner,
        'main': main ? 1 : 0,
      };
}
