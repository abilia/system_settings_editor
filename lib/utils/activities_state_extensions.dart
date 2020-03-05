import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

extension ActivitiesStateExtensions on ActivitiesState {
  Activity newActivityFromLoadedOrGiven(Activity activity) =>
      this is ActivitiesLoaded
          ? (this as ActivitiesLoaded)
              .activities
              .firstWhere((a) => a.id == activity.id, orElse: () => activity)
          : activity;
}
