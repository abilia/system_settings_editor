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
    required this.authToken,
    required this.userId,
    required this.db,
  }) : super(client, baseUrlDb) {
    fetchAllAndInsertIntoDb();
  }

  final int userId;
  final Logger log = Logger((SupportPersonsRepository).toString());
  final String authToken;
  final SupportPersonsDb db;

  Future<Iterable<SupportPerson>> fetchAllAndInsertIntoDb() async {
    log.fine('fetching support persons');
    final response = await client.get(
      '$baseUrl/api/v1/entity/$userId/roles-to'.toUri(),
      headers: authHeader(authToken),
    );
    final decoded = response.json() as List;

    db.deleteAll();
    Iterable<SupportPerson> result = decoded.where((element) {
      return element['role']['id'] == 6;
    }).map((element) {
      SupportPerson supportPerson = SupportPerson.fromJson(element['entity']);
      db.insert(supportPerson);
      return supportPerson;
    });
    return result;
  }

  Future<Iterable<SupportPerson>> loadFromDb() async {
    return await db.getAll();
  }
}
