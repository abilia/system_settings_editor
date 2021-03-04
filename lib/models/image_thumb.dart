import 'package:equatable/equatable.dart';

class ImageThumb extends Equatable {
  static const THUMB_SIZE = 350;
  final id;
  ImageThumb({
    this.id,
  });

  String get thumbId => '${id}_$THUMB_SIZE';

  @override
  List<Object> get props => [id];
}

enum ImageSize { THUMB, ORIGINAL }
