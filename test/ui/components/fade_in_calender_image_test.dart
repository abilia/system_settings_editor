import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../fakes/fakes_blocs.dart';

void main() {
  Widget wrapWithAuthBlocProvider(Widget child) =>
      BlocProvider<AuthenticationBloc>(
        create: (context) => FakeAuthenticationBloc(),
        child: child,
      );

  testWidgets('FadeInCalendarImage', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithAuthBlocProvider(const FadeInNetworkImage(
      imageFileId: 'fileid',
      imageFilePath: 'path',
    )));
    expect(find.byType(NetworkImage), findsNothing);
  });
}
