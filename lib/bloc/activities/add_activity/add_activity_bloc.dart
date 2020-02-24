import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'add_activity_event.dart';
part 'add_activity_state.dart';

class AddActivityBloc extends Bloc<AddActivityEvent, AddActivityState> {
  final Activity originalActivity;
  final ActivitiesBloc activitiesBloc;

  AddActivityBloc(this.activitiesBloc, this.originalActivity);
  @override
  AddActivityState get initialState => AddActivityState(originalActivity);

  @override
  Stream<AddActivityState> mapEventToState(
    AddActivityEvent event,
  ) async* {
    if (event is ChangeActivity) {
      yield AddActivityState(event.activity);
    }
    if (event is SaveActivity && state.canSave) {
      print('should try to save the activity');
    }
  }
}
