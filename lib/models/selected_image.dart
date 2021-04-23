import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:seagull/storage/all.dart';
import 'package:uuid/uuid.dart';

class SelectedImage extends Equatable {
  final String id;
  final String path;
  final File file;
  final bool toBeStored;

  bool get isEmpty => id.isEmpty && path.isEmpty && file == null;
  bool get isNotEmpty => !isEmpty;
  bool get hasFile => file != null;

  const SelectedImage._(
    this.id,
    this.path,
    this.file,
    this.toBeStored,
  );

  static SelectedImage from({
    String id,
    String path,
    File file,
  }) =>
      SelectedImage._(
        id ?? '',
        path ?? '',
        file,
        false,
      );

  static SelectedImage newFile(File file) {
    assert(file != null);
    assert(file.existsSync());
    final id = Uuid().v4();
    return SelectedImage._(
      id,
      '${FileStorage.folder}/$id',
      file,
      true,
    );
  }

  static const empty = SelectedImage._('', '', null, false);

  @override
  List<Object> get props => [id, path, file];
}
