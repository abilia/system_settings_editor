part of 'generic.dart';

abstract class GenericData extends Equatable {
  final String identifier;
  const GenericData(this.identifier);
  String toRaw();
  String get genericTypeString;
  String get key => uniqueId(genericTypeString, identifier);
  static String uniqueId(genericTypeString, identifier) =>
      '$genericTypeString-$identifier';

  @override
  bool get stringify => true;
}

class RawGenericData extends GenericData {
  final String data;

  const RawGenericData(this.data, String identifier) : super(identifier);

  @override
  String toRaw() => data;

  @override
  String get genericTypeString => '';

  @override
  List<Object> get props => [data, identifier];

  static RawSortableData fromJson(String data) => RawSortableData(data);
}

class MemoplannerSettingData<T> extends GenericData {
  final T data;
  final String type;

  const MemoplannerSettingData._({
    required this.data,
    required this.type,
    required String identifier,
  }) : super(identifier);

  factory MemoplannerSettingData.fromData({
    required T data,
    required String identifier,
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
        'data': data,
        'type': type,
      });

  @override
  String get genericTypeString => GenericType.memoPlannerSettings;

  @override
  List<Object?> get props => [data, type, identifier];

  factory MemoplannerSettingData.fromJson(String data, String identifier) {
    final genericData = json.decode(data);
    return MemoplannerSettingData._(
      data: genericData['data'],
      type: genericData['type'],
      identifier: identifier,
    );
  }
}
