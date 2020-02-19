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

  testWidgets('FadeInCalenderImage', (WidgetTester tester) async {
    await tester.pumpWidget(
        wrapWithAuthBlocProvider(FadeInCalenderImage(imageFileId: 'fileid')));
    expect(find.byType(NetworkImage), findsNothing);
  });
  testWidgets('FadeInThumb', (WidgetTester tester) async {
    await tester.pumpWidget(
        wrapWithAuthBlocProvider(FadeInThumb(imageFileId: 'fileid')));
    expect(find.byType(NetworkImage), findsNothing);
  });
}
