part of 'generic.dart';

abstract class GenericData extends Equatable {
  final identifier;
  const GenericData(this.identifier);
  String toRaw();
  String genericTypeString();
}

class RawGenericData extends GenericData {
  final String data;

  RawGenericData(this.data, String identifier) : super(identifier);

  @override
  String toRaw() => data;

  @override
  List<Object> get props => [data];

  static RawSortableData fromJson(String data) => RawSortableData(data);

  @override
  String genericTypeString() => null;
}

class MemoplannerSettingData<T> extends GenericData {
  final T data;
  final String type;

  const MemoplannerSettingData._({
    @required this.data,
    @required this.type,
    @required String identifier,
  }) : super(identifier);

  factory MemoplannerSettingData.fromData({
    @required dynamic data,
    @required String identifier,
  }) {
    String type;
    switch (data.runtimeType) {
      case bool:
        type = 'Boolean';
        break;
      case int:
        type = 'Integer';
        break;
      case String:
        type = 'String';
        break;
      default:
        throw UnimplementedError();
    }
    return MemoplannerSettingData._(
      data: data,
      type: type,
      identifier: identifier,
    );
  }

  @override
  String toRaw() => json.encode({
        if (data != null) 'data': data,
        if (type != null) 'type': type,
      });

  @override
  List<Object> get props => [data, type];

  factory MemoplannerSettingData.fromJson(String data, String identifier) {
    final genericData = json.decode(data);
    return MemoplannerSettingData._(
      data: genericData['data'],
      type: genericData['type'],
      identifier: identifier,
    );
  }

  @override
  String genericTypeString() => GenericType.memoPlannerSettings;
}
