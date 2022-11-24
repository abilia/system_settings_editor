import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Session extends Equatable {
  final String type, app;

  const Session({required this.type, required this.app});

  @visibleForTesting
  factory Session.mp3Session() =>
      const Session(type: 'android', app: 'memoplanner3');

  @visibleForTesting
  factory Session.mp4Session() =>
      const Session(type: 'flutter', app: 'memoplanner');

  static Session fromJson(Map<String, dynamic> json) =>
      Session(type: json['type'], app: json['app']);

  Map<String, dynamic> toJson() => {
        'type': type,
        'app': app,
      };

  @override
  List<Object?> get props => [type, app];
}
