import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class ImageAndName extends Equatable {
  final String name;
  final AbiliaFile image;
  const ImageAndName(this.name, this.image);

  static const ImageAndName empty = ImageAndName('', AbiliaFile.empty);

  ImageAndName copyWith({
    String? name,
    AbiliaFile? image,
  }) =>
      ImageAndName(
        name ?? this.name,
        image ?? this.image,
      );

  bool get hasName => name.isNotEmpty;
  bool get hasImage => image.isNotEmpty;
  bool get isEmpty => !hasName && !hasImage;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object> get props => [image, name];
}
