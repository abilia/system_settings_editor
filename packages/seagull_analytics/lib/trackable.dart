import 'package:flutter/material.dart';

abstract class Trackable {
  final Map<String, dynamic> properties;

  const Trackable(this.properties);
}

abstract class TrackableEvent extends Trackable {
  final String eventName;

  const TrackableEvent(this.eventName, super.properties);
}

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
