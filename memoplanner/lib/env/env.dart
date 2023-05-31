import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: './lib/env/.env.key')
abstract class Env {
  @EnviedField(varName: 'ABILIA_OPEN_API_KEY', obfuscate: true)
  static final String abiliaOpenAPIKey = _Env.abiliaOpenAPIKey;
}
