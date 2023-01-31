import 'package:collection/collection.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class FeatureToggleRepository extends Repository {
  FeatureToggleRepository({
    required super.client,
    required super.baseUrlDb,
    required this.userId,
  });

  final int userId;
  Uri get endpoint => '$baseUrl/api/v1/entity/$userId/features'.toUri();
  final Logger log = Logger((FeatureToggleRepository).toString());

  Future<Iterable<FeatureToggle>> getToggles() async {
    final response = await client.get(endpoint);
    if (response.statusCode == 200) {
      final decoded = response.json();
      final features = decoded['features'] as List;
      return features
          .exceptionSafeMap(
            (toggle) => FeatureToggle.values.byName(toggle),
            onException: log.logAndReturnNull,
          )
          .whereNotNull();
    } else {
      log.warning('Failed to load feature toggles');
      return [];
    }
  }
}
