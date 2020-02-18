import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/components/profile_picture.dart';

void main() {
  testWidgets('image tries to fetch and throws exception when fails',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProfilePicture(
          'url',
          User(
            username: '',
            language: '',
            id: 0,
            name: '',
            type: '',
            image: 'image',
          ),
        ),
      ),
    );
    expect(tester.takeException(), isInstanceOf<Exception>());
  });
  testWidgets('no image shows icon place holder', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProfilePicture(
          'url',
          User(
            username: '',
            language: '',
            id: 0,
            name: '',
            type: '',
            image: '',
          ),
        ),
      ),
    );
    expect(find.byIcon(AbiliaIcons.contact), findsOneWidget);
  });
}
