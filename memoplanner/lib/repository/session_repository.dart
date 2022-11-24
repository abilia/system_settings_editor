import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class SessionRepository extends Repository {
  final _log = Logger((SessionRepository).toString());
  SessionRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.sessionsDb,
  }) : super(client, baseUrlDb);

  final SessionDb sessionsDb;

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

  Future<void> setSession(Session? session) => sessionsDb.setSession(session);

  Session get session => sessionsDb.session;
}
