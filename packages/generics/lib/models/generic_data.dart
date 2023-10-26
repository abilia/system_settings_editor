part of 'generic.dart';

abstract class GenericData extends Equatable {
  final String identifier, type, key;
  final dynamic dynamicData;
  const GenericData({
    required this.identifier,
    required this.type,
    required this.dynamicData,
  }) : key = '$type-$identifier';
  String toRaw();

  @override
  bool get stringify => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenericData && equals(props, other.props);

  @override
  int get hashCode => mapPropsToHashCode(props);
}

class RawGenericData extends GenericData {
  final String data;

  const RawGenericData({
    required super.identifier,
    required super.type,
    required this.data,
  }) : super(dynamicData: data);

  @override
  String toRaw() => data;

  @override
  List<Object> get props => [identifier, type, data];
}

class GenericSettingData<T> extends GenericData {
  final T data;
  final String dataType;
  @override
  GenericSettingData({
    required super.identifier,
    required super.type,
    required this.data,
  })  : dataType = typeString(data.runtimeType),
        super(dynamicData: data);

  static String typeString(Type type) {
    switch (type) {
      case bool:
        return 'Boolean';
      case int:
        return 'Integer';
      case String:
        return 'String';
      default:
        throw UnimplementedError();
    }
  }

  @override
  String toRaw() => json.encode({
        'data': data,
        'type': dataType,
      });

  @override
  List<Object?> get props => [identifier, type, data, dataType];

  factory GenericSettingData.fromJson({
    required String identifier,
    required String type,
    required String jsonData,
  }) {
    final genericData = json.decode(jsonData);
    return GenericSettingData(
      identifier: identifier,
      type: type,
      data: genericData['data'],
    );
  }
}
