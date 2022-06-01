import 'package:equatable/equatable.dart';

class SupportPerson extends Equatable {
  const SupportPerson(
      {required this.id, required this.name, required this.image});

  final int id;
  final String name;
  final String image;

  @override
  List<Object?> get props => [name];

  @override
  bool? get stringify => true;

  Map<String, dynamic> toMapForDb() => {
        'id': id,
        'name': name,
        'image': image,
      };

  static SupportPerson fromDbMap(Map<String, dynamic> dbRow) => SupportPerson(
        id: dbRow['id'],
        name: dbRow['name'],
        image: dbRow['image'],
      );

  static SupportPerson fromJson(Map<String, dynamic> json) => SupportPerson(
        id: json['id'],
        name: json['name'],
        image: json['image'],
      );
}
