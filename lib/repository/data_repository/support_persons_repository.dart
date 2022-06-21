import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
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
  static const supportPersonRoleId = 6;

  Future<Iterable<SupportPerson>> load() async {
    try {
      log.fine('fetching support persons');
      final response = await client.get(
        '$baseUrl/api/v1/entity/$userId/roles-to'.toUri(),
      );
      if (response.statusCode == 200) {
        final decoded = response.json() as List;
        await db.deleteAll();
        Iterable<SupportPerson> result = decoded.where((element) {
          return element['role']['id'] == supportPersonRoleId;
        }).map(
          (element) => SupportPerson.fromJson(
            element['entity'],
          ),
        );
        db.insertAll(result);
      }
    } catch (e) {
      log.severe('Error when fetching support persons, offline?', e);
    }
    return db.getAll();
  }
}
