import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:seagull/models/activity.dart';

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
    await analytics.logEvent(
      name: 'activity_created',
      parameters: <String, dynamic>{
        'image': activity.hasImage,
        'title': activity.title?.isNotEmpty ?? false,
        'fullDay': activity.fullDay,
        'checkable': activity.checkable,
        'removeAfter': activity.removeAfter,
        'alarm': activity.alarm.toInt,
        'recurring': activity.recurrance.toString(),
      },
    );
  }
}