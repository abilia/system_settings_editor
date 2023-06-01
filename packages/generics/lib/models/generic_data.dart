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
}

class GenericSettingData<T> extends GenericData {
  final T data;
  final String type;

  const GenericSettingData._({
    required this.data,
    required this.type,
    required String identifier,
  }) : super(identifier);

  factory GenericSettingData.fromData({
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
    return GenericSettingData._(
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

  factory GenericSettingData.fromJson(String data, String identifier) {
    final genericData = json.decode(data);
    return GenericSettingData._(
      data: genericData['data'],
      type: genericData['type'],
      identifier: identifier,
    );
  }
}
