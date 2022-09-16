import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class SessionRepository extends Repository {
  final _log = Logger((SessionRepository).toString());
  SessionRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.sessionsDb,
  }) : super(client, baseUrlDb);

  final SessionsDb sessionsDb;

  Future<bool> hasMP4Session() async {
    final url = '$baseUrl/api/v1/auth/client';
    final response = await client.get(
      url.toUri(),
    );

    if (response.statusCode == 200) {
      final decoded = response.json() as List;
      final sessions = decoded
          .exceptionSafeMap(
            (j) => Session.fromJson(j),
            onException: _log.logAndReturnNull,
          )
          .whereNotNull();

      final hasMP4Session =
          sessions.any((s) => s.type == 'flutter' && s.app == 'memoplanner');
      await sessionsDb.setHasMP4Session(hasMP4Session);
      return hasMP4Session;
    } else {
      return sessionsDb.hasMP4Session;
    }
  }
}
