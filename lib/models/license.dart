import 'package:equatable/equatable.dart';

const memoplannerLicenseName = 'memoplanner3';

class License extends Equatable {
  final int id;
  final String product;
  final DateTime endTime;

  const License({
    required this.id,
    required this.product,
    required this.endTime,
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
        'product': product,
        'endTime': endTime.millisecondsSinceEpoch,
      };

  @override
  List<Object> get props => [id, product, endTime];
  @override
  bool get stringify => true;
}
