import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/utils/all.dart';

class ActivityListener extends BlocListener<ActivitiesBloc, ActivitiesState> {
  ActivityListener({
    Key? key,
    required Activity activity,
    required Function() onActivityDeleted,
    required Widget child,
  }) : super(
          key: key,
          listener: (context, state) {
            final updatedActivity = state.newActivityFromLoadedOrNull(activity);
            if (updatedActivity == null) {
              onActivityDeleted();
            }
          },
          child: child,
        );
}
