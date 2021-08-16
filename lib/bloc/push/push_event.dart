part of 'push_bloc.dart';

class PushEvent {
  final String? collapseKey;
  const PushEvent(this.collapseKey);
  @override
  String toString() => 'PushEvent {$collapseKey}';
}
