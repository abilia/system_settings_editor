import 'package:equatable/equatable.dart';
import 'package:memoplanner/utils/all.dart';

const memoplannerLicenseName = 'memoplanner';
const licenseLength = 12;

class License extends Equatable {
  final int id;
  final String _key;
  final String product;
  final DateTime endTime;

  const License({
    required this.id,
    required String key,
    required this.product,
    required this.endTime,
  }) : _key = key;

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      id: json['id'],
      key: json['licenseKey'] ?? '',
      product: json['product'],
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'licenseKey': _key.nullOnEmpty(),
        'product': product.nullOnEmpty(),
        'endTime': endTime.millisecondsSinceEpoch,
      };

  @override
  List<Object> get props => [id, product, endTime];

  @override
  bool get stringify => true;
}

class DeviceLicense {
  final String serialNumber;
  final String? product;
  final DateTime? endTime;
  final String? licenseKey;

  String get formattedKey {
    final value = RegExp(r'.{4}')
        .allMatches(licenseKey ?? '')
        .map((m) => m.group(0))
        .join('-');
    return value;
  }

  DeviceLicense.fromJson(Map<String, dynamic> json)
      : serialNumber = json['serialNumber'],
        product = json['product'],
        endTime = json['endTime'] is int
            ? DateTime.fromMillisecondsSinceEpoch(json['endTime'])
            : null,
        licenseKey = json['licenseKey'];

  Map<String, dynamic> toJson() => {
        'serialNumber': serialNumber,
        'licenseKey': licenseKey,
        'product': product?.nullOnEmpty(),
        'endTime': endTime?.millisecondsSinceEpoch,
      };
}
