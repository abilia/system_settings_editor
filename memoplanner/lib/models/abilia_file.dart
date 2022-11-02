import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:uuid/uuid.dart';

class AbiliaFile extends Equatable {
  final String id;
  final String path;

  bool get isEmpty => id.isEmpty && path.isEmpty;
  bool get isNotEmpty => !isEmpty;

  const AbiliaFile._(
    this.id,
    this.path,
  );

  factory AbiliaFile.from({String? id, String? path}) =>
      AbiliaFile._(id ?? '', path ?? '');

  static const empty = AbiliaFile._('', '');

  @override
  List<Object?> get props => [id, path];
}

class UnstoredAbiliaFile extends AbiliaFile {
  final File file;

  const UnstoredAbiliaFile._(
    String id,
    String path,
    this.file,
  ) : super._(id, path);

  factory UnstoredAbiliaFile.newFile(File file) {
    final id = const Uuid().v4();
    return UnstoredAbiliaFile._(
      id,
      '${FileStorage.folder}/$id',
      file,
    );
  }

  @visibleForTesting
  factory UnstoredAbiliaFile.forTest(String id, String path, File file) =>
      UnstoredAbiliaFile._(id, path, file);

  @override
  List<Object?> get props => [...super.props, file];
}
