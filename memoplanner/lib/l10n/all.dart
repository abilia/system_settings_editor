import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';

export 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
export 'generated/l10n.dart';
export 'translations_extensions.dart';

Future<void> initLokalise() => Lokalise.init(
      projectId: '5478615164886d27c51a59.58833679',
      sdkToken: 'd3fbf2cb3b69f06694974560af79cb31fc6b',
    );
