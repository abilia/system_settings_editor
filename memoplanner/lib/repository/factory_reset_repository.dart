import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

class FactoryResetRepository extends Repository {
  final Logger _log = Logger((FactoryResetRepository).toString());

  FactoryResetRepository({
    required BaseClient client,
    required BaseUrlDb baseUrlDb,
  }) : super(client, baseUrlDb);

  Future<bool> factoryResetDevice() async {
    await Future.delayed(3.seconds());
    return false;
  }
}
