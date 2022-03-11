import 'package:flutter_bloc/flutter_bloc.dart';

class ActivityDetectionCubit extends Cubit<ActivityDetected> {
  ActivityDetectionCubit() : super(const ActivityDetected());

  void activityDetected([_]) => emit(const ActivityDetected());
}

class ActivityDetected {
  const ActivityDetected();
}
