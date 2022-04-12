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

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'owner': owner,
        'main': main,
      };
}
