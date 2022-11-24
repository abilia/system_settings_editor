import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class SessionsRepository extends Repository {
  final _log = Logger((SessionsRepository).toString());
  SessionsRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.sessionsDb,
  }) : super(client, baseUrlDb);

  final SessionsDb sessionsDb;

  Future<Iterable<Session>> fetchSessions() async {
    final url = '$baseUrl/api/v1/auth/client';
    final response = await client.get(
      url.toUri(),
    );

    if (response.statusCode == 200) {
      final decoded = response.json() as List;
      return decoded
          .exceptionSafeMap(
            (j) => Session.fromJson(j),
            onException: _log.logAndReturnNull,
          )
          .whereNotNull();
    }
    throw FetchSessionsException(response.statusCode);
  }

  Future<void> setHasMP4Session(bool hasMP4Session) =>
      sessionsDb.setHasMP4Session(hasMP4Session);

  bool hasMP4Session() => sessionsDb.hasMP4Session;
}
