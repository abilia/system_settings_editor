import 'package:meta/meta.dart';

class License {
  final int id;
  final String product;
  final DateTime endTime;

  License({
    @required this.id,
    @required this.product,
    @required this.endTime,
  });

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      id: json['id'],
      product: json['product'],
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': 'product',
        'endTime': endTime.millisecondsSinceEpoch,
      };
}
