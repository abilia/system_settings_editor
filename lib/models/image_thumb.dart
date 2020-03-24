import 'package:equatable/equatable.dart';

class ImageThumb extends Equatable {
  final id;
  final height;
  final width;

  ImageThumb(this.id, this.height, this.width);

  String get thumbId => '${id}_${height}_${width}';

  @override
  List<Object> get props => [id, height, width];
}
