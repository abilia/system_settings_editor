import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/utils/all.dart';

class ActivityListener extends BlocListener<ActivitiesBloc, ActivitiesState> {
  ActivityListener({
    required Activity activity,
    required Function() onActivityDeleted,
    required Widget child,
    Key? key,
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
