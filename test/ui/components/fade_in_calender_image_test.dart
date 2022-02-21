import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/ui/components/all.dart';

import '../../fakes/all.dart';

void main() {
  Widget wrapWithAuthBlocProvider(Widget child) =>
      BlocProvider<AuthenticationBloc>(
        create: (context) => FakeAuthenticationBloc(),
        child: child,
      );
  setUp(() async {
    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  testWidgets('FadeInCalendarImage', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithAuthBlocProvider(const FadeInNetworkImage(
      imageFileId: 'fileid',
      imageFilePath: 'path',
    )));
    expect(find.byType(NetworkImage), findsNothing);
  });
}
