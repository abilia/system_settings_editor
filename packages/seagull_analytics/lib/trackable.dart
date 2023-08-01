import 'package:flutter/material.dart';

abstract class Trackable {
  final Map<String, dynamic>? properties;

  const Trackable(this.properties);
}

class TrackableRouteSettings extends RouteSettings implements Trackable {
  @override
  final Map<String, dynamic>? properties;

  const TrackableRouteSettings({required super.name, this.properties});
}

extension TypeRoute on Type {
  TrackableRouteSettings routeSetting({Map<String, dynamic>? properties}) =>
      TrackableRouteSettings(
        name: toString(),
        properties: properties,
      );
}
