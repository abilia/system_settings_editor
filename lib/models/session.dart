class Session {
  Session({
    required this.type,
    required this.app,
  });
  final String type, app;

  static Session fromJson(Map<String, dynamic> json) =>
      Session(type: json['type'], app: json['app']);
}
