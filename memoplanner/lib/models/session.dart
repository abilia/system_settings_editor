import 'package:equatable/equatable.dart';

class Session extends Equatable {
  const Session({
    required this.type,
    required this.app,
  });
  final String type, app;

  static Session fromJson(Map<String, dynamic> json) =>
      Session(type: json['type'], app: json['app']);

  Map<String, dynamic> toJson() => {
        'type': type,
        'app': app,
      };

  @override
  List<Object?> get props => [type, app];
}
