import 'package:equatable/equatable.dart';

class ImageThumb extends Equatable {
  static const DEFAULT_THUMB_SIZE = 350;

  final id;
  final height;
  final width;

  ImageThumb({
    this.id,
    this.height = DEFAULT_THUMB_SIZE,
    this.width = DEFAULT_THUMB_SIZE,
  });

  String get thumbId => '${id}_${height}_${width}';

  @override
  List<Object> get props => [id, height, width];
}
