import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:uuid/uuid.dart';

class SelectedImage extends Equatable {
  final String id;
  final String path;
  final File file;

  bool get isEmpty => id.isEmpty && path.isEmpty && file == null;
  bool get isNotEmpty => !isEmpty;

  const SelectedImage._(
    this.id,
    this.path, {
    this.file,
  });

  @visibleForTesting
  factory SelectedImage.forTest(String id, String path, File file) =>
      SelectedImage._(id, path, file: file);

  factory SelectedImage.from({String id, String path}) =>
      SelectedImage._(id ?? '', path ?? '');

  factory SelectedImage.newFile(File file) {
    assert(file != null);
    assert(file.existsSync());
    final id = Uuid().v4();
    return SelectedImage._(
      id,
      '${FileStorage.folder}/$id',
      file: file,
    );
  }

  static const empty = SelectedImage._('', '');

  @override
  List<Object> get props => [id, path, file];
}
