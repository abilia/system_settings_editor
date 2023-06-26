import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';
import 'package:support_persons/support_persons.dart';
import 'package:utils/utils.dart';

class SupportPersonsRepository extends Repository {
  SupportPersonsRepository({
    required super.client,
    required super.baseUrlDb,
    required this.userId,
    required this.db,
  });

  final int userId;
  final Logger log = Logger((SupportPersonsRepository).toString());
  final SupportPersonsDb db;
  static const supportPersonRoleId = 6;

  Future<Set<SupportPerson>> load() async {
    try {
      log.fine('fetching support persons');
      final response = await client.get(
        '$baseUrl/api/v1/entity/$userId/roles-to'.toUri(),
      );
      if (response.statusCode != 200) {
        log.warning('Error when fetching support persons, offline? $response');
      }

      final decoded = response.json() as List;
      final result = decoded
          .where((element) => element['role']?['id'] == supportPersonRoleId)
          .exceptionSafeMap(
            (element) => SupportPerson.fromJson(element['entity']),
            onException: log.logAndReturnNull,
          )
          .whereNotNull();
      await db.insertAll(result);
    } catch (e) {
      log.severe('Error when parsing support persons', e);
    }
    return db.getAll();
  }
}
