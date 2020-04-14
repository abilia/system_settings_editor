import 'package:equatable/equatable.dart';

class ImageThumb extends Equatable {
  static const SMALL_THUMB_SIZE = 350;
  static const MEDIUM_THUMB_SIZE = 750;

  final id;
  final size;

  ImageThumb({
    this.id,
    this.size = MEDIUM_THUMB_SIZE,
  });

  String get thumbId => '${id}_${size}';

  @override
  List<Object> get props => [id, size];
}

class MediumThumb extends ImageThumb {
  MediumThumb(String id) : super(id: id, size: ImageThumb.MEDIUM_THUMB_SIZE);
}

class SmallThumb extends ImageThumb {
  SmallThumb(String id) : super(id: id, size: ImageThumb.SMALL_THUMB_SIZE);
}
