import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class FeatureToggleRepository extends Repository {
  FeatureToggleRepository({
    required super.client,
    required super.baseUrlDb,
    required this.userId,
  });

  final int userId;
  final Logger _log = Logger((FeatureToggleRepository).toString());

  Uri get endpoint => '$baseUrl/api/v1/entity/$userId/features'.toUri();

  Future<Iterable<FeatureToggle>> getToggles() async {
    try {
      final response = await client.get(endpoint);
      if (response.statusCode == 200) {
        final decoded = response.json();
        final features = decoded['features'] as List;
        return features
            .exceptionSafeMap(
              (toggle) => FeatureToggle.values.byName(toggle),
              onException: _log.logAndReturnNull,
            )
            .whereNotNull();
      } else {
        _log.warning(
          'Failed to load feature toggles with status code ${response.statusCode}',
        );
      }
    } catch (error) {
      _log.warning('Failed to load feature toggles', error);
    }
    return [];
  }
}
