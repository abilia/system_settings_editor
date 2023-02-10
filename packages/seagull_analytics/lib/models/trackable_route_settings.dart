import 'package:flutter/material.dart';
import 'package:seagull_analytics/all.dart';

extension TypeRoute on Type {
  TrackableRouteSettings routeSetting({Map<String, dynamic>? properties}) =>
      TrackableRouteSettings(
        name: toString(),
        properties: properties ?? {},
      );
}

class TrackableRouteSettings extends RouteSettings implements Trackable {
  @override
  final Map<String, dynamic> properties;

  const TrackableRouteSettings({required super.name, required this.properties});
}
