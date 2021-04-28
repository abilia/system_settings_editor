import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class ImageAndName extends Equatable {
  final String name;
  final SelectedImage image;
  const ImageAndName(this.name, this.image);

  static ImageAndName get empty =>
      const ImageAndName(null, SelectedImage.empty);

  ImageAndName copyWith({
    String name,
    SelectedImage image,
  }) =>
      ImageAndName(
        name ?? this.name,
        image ?? this.image,
      );

  bool get hasName => name?.isNotEmpty == true;
  bool get isEmpty => !hasName && image.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object> get props => [image, name];
}
