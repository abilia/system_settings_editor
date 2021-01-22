import 'dart:io';

import 'package:equatable/equatable.dart';

class SelectedImage extends Equatable {
  final String id;
  final String path;
  final File file;

  bool get isEmpty => id.isEmpty && path.isEmpty && file == null;
  bool get isNotEmpty => !isEmpty;

  SelectedImage({
    String id,
    String path,
    this.file,
  })  : id = id ?? '',
        path = path ?? '';

  factory SelectedImage.none() => SelectedImage();

  @override
  List<Object> get props => [id, path, file];
}
