import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class User extends Equatable {
  final int id;
  final String type;
  final String name;
  final String username;
  final String language;
  final String image;
  User({this.username, this.language, this.image, @required this.id, @required this.type, @required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], type: json['type'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'name': name};

  @override
  List<Object> get props => [
    id,
    type,
    name,
    username,
    language,
    image,
  ];
}
