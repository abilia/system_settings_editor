import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/db/support_persons_db.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/support_person.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

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

  Future<Iterable<SupportPerson>> load() async {
    try {
      log.fine('fetching support persons');
      final response = await client.get(
        '$baseUrl/api/v1/entity/$userId/roles-to'.toUri(),
      );
      final decoded = response.json() as List;

      db.deleteAll();
      Iterable<SupportPerson> result = decoded.where((element) {
        return element['role']['id'] == 6; // '6' is the role id of support person in myabilia
      }).map((element) => SupportPerson.fromJson(element['entity'],),);
      db.insertAll(result);
      return result;
    } catch (e) {
      log.severe('Error when fetching support persons, offline?', e);
      return db.getAll();
    }
  }
}
