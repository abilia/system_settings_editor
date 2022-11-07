import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/ui/components/abilia_icons.dart';
import 'package:memoplanner/ui/components/profile_picture.dart';

void main() {
  testWidgets('no image shows icon place holder', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ProfilePicture(
          'url',
          '',
        ),
      ),
    );
    expect(find.byIcon(AbiliaIcons.contact), findsOneWidget);
  });
}
