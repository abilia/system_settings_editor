import 'package:equatable/equatable.dart';

const memoplannerLicenseName = 'memoplanner';

class License extends Equatable {
  final int id;
  final String key;
  final String product;
  final DateTime endTime;

  const License({
    required this.id,
    required this.key,
    required this.product,
    required this.endTime,
  });

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
        'licenseKey': key,
        'product': product,
        'endTime': endTime.millisecondsSinceEpoch,
      };

  @override
  List<Object> get props => [id, product, endTime];
  @override
  bool get stringify => true;
}
