import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityButton extends StatelessWidget {
  const AddActivityButton({
    Key? key,
    required this.day,
  }) : super(key: key);

  final DateTime day;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, state) => TextActionButtonLight(
          Translator.of(context).translate.newActivityButton,
          AbiliaIcons.plus,
          onPressed: () {
            if (!_canAddActivity(context, state)) {
              _showNoBasicActivityError(context);
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CopiedAuthProviders(
                  blocContext: context,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<EditActivityBloc>(
                        create: (_) => EditActivityBloc.newActivity(
                          day: day,
                          defaultAlarmTypeSetting:
                              state.defaultAlarmTypeSetting,
                        ),
                      ),
                      BlocProvider(
                        create: (context) => ActivityWizardCubit.newActivity(
                            activitiesBloc: context.read<ActivitiesBloc>(),
                            editActivityBloc: context.read<EditActivityBloc>(),
                            clockBloc: context.read<ClockBloc>(),
                            settings: state),
                      ),
                    ],
                    child: const ActivityWizardPage(),
                  ),
                ),
              ),
            );
          },
        ),
      );

  bool _canAddActivity(
          BuildContext context, MemoplannerSettingsState settingState) =>
      !settingState.settings.wizard.onlyTemplateStep ||
      context
          .read<SortableBloc>()
          .state
          .hasSortableOfType<BasicActivityDataItem>();

  void _showNoBasicActivityError(BuildContext context) {
    final t = Translator.of(context).translate;
    showViewDialog(
      context: context,
      builder: (context) => ErrorDialog(
        text: '${t.noBasicActivityError1}\n'
            '\n${t.noBasicActivityError2}',
      ),
    );
  }
}
