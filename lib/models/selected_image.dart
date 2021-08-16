import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:uuid/uuid.dart';

class SelectedImage extends Equatable {
  final String id;
  final String path;

  bool get isEmpty => id.isEmpty && path.isEmpty;
  bool get isNotEmpty => !isEmpty;

  const SelectedImage._(
    this.id,
    this.path,
  );

  factory SelectedImage.from({String? id, String? path}) =>
      SelectedImage._(id ?? '', path ?? '');

  static const empty = SelectedImage._('', '');

  @override
  List<Object?> get props => [id, path];
}

class SelectedImageFile extends SelectedImage {
  final File file;

  const SelectedImageFile._(
    String id,
    String path,
    this.file,
  ) : super._(id, path);

  factory SelectedImageFile.newFile(File file) {
    assert(file.existsSync());
    final id = Uuid().v4();
    return SelectedImageFile._(
      id,
      '${FileStorage.folder}/$id',
      file,
    );
  }

  @visibleForTesting
  factory SelectedImageFile.forTest(String id, String path, File file) =>
      SelectedImageFile._(id, path, file);

  @override
  List<Object?> get props => [...super.props, file];
}
