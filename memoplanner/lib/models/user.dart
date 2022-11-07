import 'package:equatable/equatable.dart';
import 'package:memoplanner/utils/all.dart';

class User extends Equatable {
  final int id;
  final String type;
  final String name;
  final String username;
  final String language;
  final String image;
  const User({
    required this.id,
    required this.type,
    required this.name,
    this.username = '',
    this.language = '',
    this.image = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      type: json['type'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      language: json['language'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.nullOnEmpty(),
        'name': name.nullOnEmpty(),
        'username': username.nullOnEmpty(),
        'language': language.nullOnEmpty(),
        'image': image.nullOnEmpty(),
      };

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
