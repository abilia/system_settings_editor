import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../mocks.dart';

void main() {
  final authBloc = MockAuthenticationBloc();
  Widget wrapWithAuthBlocProvider(Widget child) =>
      BlocProvider<AuthenticationBloc>(
        create: (context) => authBloc,
        child: child,
      );

  testWidgets('FadeInCalendarImage', (WidgetTester tester) async {
    await tester.pumpWidget(
        wrapWithAuthBlocProvider(FadeInCalendarImage(imageFileId: 'fileid', imageFilePath: 'path',)));
    expect(find.byType(NetworkImage), findsNothing);
  });
}
