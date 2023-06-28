import 'package:equatable/equatable.dart';
import 'package:utils/utils.dart';

class SupportPerson extends Equatable {
  const SupportPerson({
    required this.id,
    required this.name,
    required this.image,
  });

  final int id;
  final String name;
  final String image;

  @override
  List<Object?> get props => [id, name, image];

  @override
  bool? get stringify => true;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.nullOnEmpty(),
        'image': image.nullOnEmpty(),
      };

  static SupportPerson fromJson(Map<String, dynamic> json) => SupportPerson(
        id: json['id'],
        name: json['name'],
        image: json['image'] ?? '',
      );
}
