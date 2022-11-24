import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/support_person.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class SupportPersonsRepository extends Repository {
  SupportPersonsRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.userId,
    required this.db,
  }) : super(client, baseUrlDb);

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
