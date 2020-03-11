import 'package:meta/meta.dart';

@immutable
class PushEvent {
  final String collapseKey;
  const PushEvent(this.collapseKey);
}
