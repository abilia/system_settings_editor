import 'package:handi/main.dart';
import 'package:patrol/patrol.dart';

Future<void> pumpAndSettleHandiApp(PatrolIntegrationTester patrol) async {
  await initServices();
  await patrol.pumpWidgetAndSettle(const HandiApp());
}
