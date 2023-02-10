abstract class Trackable {
  final Map<String, dynamic> properties;

  const Trackable(this.properties);
}

abstract class TrackableEvent extends Trackable {
  final String eventName;

  const TrackableEvent(this.eventName, super.properties);
}
