part of 'add_activity_bloc.dart';

abstract class AddActivityEvent extends Equatable {
  const AddActivityEvent();
}

class ChangeActivity extends AddActivityEvent {
  final Activity activity;
  ChangeActivity(this.activity);

  @override
  List<Object> get props => [activity];
  @override
  String toString() => 'ChangeActivity { $activity }';
}

class SaveActivity extends AddActivityEvent {
  @override
  List<Object> get props => [];
}
