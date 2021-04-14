import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:seagull/models/all.dart';

class AnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static Future<void> sendLoginEvent() async {
    await analytics.logLogin();
  }

  static Future<void> setUserId(int id) async {
    await analytics.setUserId(id.toString());
  }

  static Future<void> sendActivityCreatedEvent(Activity activity) async {
    final params = <String, dynamic>{
      'image': activity.hasImage,
      'title': activity.hasTitle ?? false,
      'fullDay': activity.fullDay,
      'checkable': activity.checkable,
      'removeAfter': activity.removeAfter,
      'alarm': activity.alarm.toInt,
      'recurring': activity.recurs.recurrance.toString(),
    };
    await analytics.logEvent(
      name: 'activity_created',
      parameters: params,
    );
  }
}
