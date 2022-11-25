import 'dart:convert';

import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class TermsOfUseRepository extends Repository {
  final TermsOfUseDb termsOfUseDb;
  final int userId;
  final Logger _log = Logger((TermsOfUseRepository).toString());

  TermsOfUseRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.termsOfUseDb,
    required this.userId,
  }) : super(client, baseUrlDb);

  Uri get endpoint => '$baseUrl/api/v1/entity/$userId/acknowledgments'.toUri();

  Future<bool> isTermsOfUseAccepted() async {
    try {
      if (termsOfUseDb.termsOfUseAccepted) return true;
      final response = await client.get(endpoint);
      if (response.statusCode == 200) {
        final decoded = response.json();
        return TermsOfUse.fromMap(decoded).allAccepted;
      }
      _log.warning(
        'Could not fetch terms of use from backend with status code '
        '${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      _log.warning('Could not fetch terms of use from backend $e');
    }
    // If fetching terms of use fails and throws an exception,
    // we do not want to show a terms of use dialog
    return true;
  }

  Future<void> acceptTermsOfUse() async {
    try {
      final response = await client.post(
        endpoint,
        headers: jsonHeader,
        body: jsonEncode(TermsOfUse.accepted().toMap()),
      );
      if (response.statusCode == 200) {
        return await termsOfUseDb.setTermsOfUseAccepted(true);
      }
      _log.warning(
        'Could not post terms of use from backend with status code '
        '${response.statusCode}: ${response.body}',
      );
    } catch (error) {
      _log.warning('Could not set terms of use', error);
    }
  }
}
