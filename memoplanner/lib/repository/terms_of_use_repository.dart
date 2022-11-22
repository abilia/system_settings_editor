import 'dart:convert';

import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class TermsOfUseRepository extends Repository {
  final TermsOfUseDb termsOfUseDb;
  final int userId;

  TermsOfUseRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
    required this.termsOfUseDb,
    required this.userId,
  }) : super(client, baseUrlDb);

  Uri get endpoint => '$baseUrl/api/v1/entity/$userId/acknowledgments'.toUri();

  Future<TermsOfUse> loadTermsOfUse() async {
    if (termsOfUseDb.termsOfUseAccepted) {
      return TermsOfUse.accepted();
    }
    return fetchTermsOfUse();
  }

  Future<TermsOfUse> fetchTermsOfUse() async {
    try {
      final response = await client.get(endpoint);
      if (response.statusCode == 200) {
        final decoded = response.json();
        return TermsOfUse.fromMap(decoded);
      }
      throw FetchTermsOfUseException(response.statusCode);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> saveTermsOfUse(TermsOfUse termsOfUse) async {
    final success = await postTermsOfUse(termsOfUse);
    if (success) {
      await termsOfUseDb.setTermsOfUseAccepted(termsOfUse.allAccepted);
    }
  }

  Future<bool> postTermsOfUse(TermsOfUse termsOfUse) async {
    try {
      final response = await client.post(
        endpoint,
        headers: jsonHeader,
        body: jsonEncode({
          'termsOfCondition': termsOfUse.termsOfCondition,
          'privacyPolicy': termsOfUse.privacyPolicy
        }),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}
