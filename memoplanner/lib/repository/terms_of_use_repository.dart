import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class TermsOfUseRepository extends Repository {
  final SessionsDb sessionsDb;
  final int userId;

  TermsOfUseRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.sessionsDb,
    required this.userId,
  }) : super(client, baseUrlDb);

  Future<TermsOfUse> fetchTermsOfUse() async {
    try {
      final response = await client.get(
        '$baseUrl/api/v1//entity//$userId/acknowledgments'.toUri(),
      );
      if (response.statusCode == 200) {
        final decoded = response.json();
        return TermsOfUse.fromJson(decoded);
      }
      throw FetchTermsOfUseException(response.statusCode);
    } catch (error) {
      rethrow;
    }
  }
}
