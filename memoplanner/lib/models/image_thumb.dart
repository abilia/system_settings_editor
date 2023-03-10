import 'package:equatable/equatable.dart';

class ImageThumb extends Equatable {
  static const thumbSize = 350;
  final String id;
  const ImageThumb({required this.id});

  String get thumbId => '${id}_$thumbSize';

  @override
  List<Object> get props => [id];
}

enum ImageSize { thumb, original }
