import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class DataModel extends Equatable {
  final String id;

  const DataModel(this.id) : assert(id != null);
  DbModel wrapWithDbModel({int revision = 0, int dirty = 0});
}

abstract class DbModel<M extends DataModel> extends Equatable {
  final int dirty, revision;
  final M model;

  const DbModel({
    @required this.dirty,
    @required this.revision,
    @required this.model,
  })  : assert(dirty >= 0),
        assert(revision >= 0),
        assert(model != null);
  Map<String, dynamic> toMapForDb();
  Map<String, dynamic> toJson();
  DbModel<M> copyWith({
    int revision,
    int dirty,
  });
}