part of 'generic.dart';

abstract class GenericData extends Equatable {
  final identifier;
  const GenericData(this.identifier);
  String toRaw();
}

class RawGenericData extends GenericData {
  final String data;

  RawGenericData(this.data, String identifier) : super(identifier);

  @override
  String toRaw() => data;

  @override
  List<Object> get props => [data];

  static RawSortableData fromJson(String data) => RawSortableData(data);
}

class MemoplannerSettingData extends GenericData {
  final String data, type;

  const MemoplannerSettingData({
    @required this.data,
    @required this.type,
    @required String identifier,
  }) : super(identifier);

  @override
  String toRaw() => json.encode({
        if (data != null) 'data': data,
        if (type != null) 'type': type,
      });

  @override
  List<Object> get props => [data, type];

  factory MemoplannerSettingData.fromJson(String data, String identifier) {
    final genericData = json.decode(data);
    return MemoplannerSettingData(
      data: genericData['data'].toString(),
      type: genericData['type'],
      identifier: identifier,
    );
  }
}
