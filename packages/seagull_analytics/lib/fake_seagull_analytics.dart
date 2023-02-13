import 'package:equatable/equatable.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class AnalyticsEvent extends Equatable {
  final String eventName;
  final Map<String, dynamic> properties;

  const AnalyticsEvent(this.eventName, this.properties);

  @override
  List<Object?> get props => [eventName, properties];

  @override
  bool get stringify => true;
}

class FakeSeagullAnalytics extends SeagullAnalytics {
  final List<AnalyticsEvent> events;

  FakeSeagullAnalytics()
      : events = [],
        super(null, {});

  @override
  void trackEvent(
    String eventName, {
    required Map<String, dynamic> properties,
  }) {
    if (events.length > 100) events.removeAt(0);
    final event = AnalyticsEvent(eventName, {...properties});
    events.add(event);
  }
}
