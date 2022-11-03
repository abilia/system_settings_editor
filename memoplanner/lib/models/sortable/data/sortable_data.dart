import 'package:equatable/equatable.dart';
import 'package:memoplanner/i18n/all.dart';

abstract class SortableData extends Equatable {
  const SortableData();

  String toRaw();

  String title(Translated t);

  String dataFileId();

  String dataFilePath();

  bool hasImage();
}

class RawSortableData extends SortableData {
  final String data;

  const RawSortableData(this.data);

  @override
  String toRaw() => data;

  @override
  List<Object> get props => [data];

  static RawSortableData fromJson(String data) => RawSortableData(data);

  @override
  String title(t) => '';

  @override
  String dataFileId() => '';

  @override
  String dataFilePath() => '';

  @override
  bool hasImage() => false;
}
