import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class ActivityViewSettingsCubit extends Cubit<ActivityViewSettings> {
  final GenericCubit genericCubit;

  ActivityViewSettingsCubit({
    required ActivityViewSettings activityViewSettings,
    required this.genericCubit,
  }) : super(activityViewSettings);

  void changeSettings(ActivityViewSettings settings) => emit(settings);
  Future<void> save() =>
      genericCubit.genericUpdated(state.memoplannerSettingData);
}
