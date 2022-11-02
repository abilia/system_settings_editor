import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class ActivityViewSettingsCubit extends Cubit<ActivityViewSettings> {
  final GenericCubit genericCubit;

  ActivityViewSettingsCubit({
    required ActivityViewSettings activityViewSettings,
    required this.genericCubit,
  }) : super(activityViewSettings);

  void changeSettings(ActivityViewSettings settings) => emit(settings);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
