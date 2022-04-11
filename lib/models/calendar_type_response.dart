class CalendarType {
  final String id, type;
  final int owner;
  final bool main;

  const CalendarType._(
    this.id,
    this.type,
    this.owner,
    this.main,
  );

  factory CalendarType.fromJson(Map<String, dynamic> json) => CalendarType._(
        json['id'],
        json['type'],
        json['owner'],
        json['main'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'owner': owner,
        'main': main,
      };
}
