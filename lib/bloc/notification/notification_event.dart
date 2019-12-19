import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
}

class NotificationSelected extends NotificationEvent {
  final Payload payload;
  NotificationSelected(this.payload);
  @override
  List<Object> get props => [payload];
}
