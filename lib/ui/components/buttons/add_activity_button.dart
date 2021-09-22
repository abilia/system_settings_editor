import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/edit_activity/activity_wizard_page.dart';

class AddActivityButton extends StatelessWidget {
  const AddActivityButton({
    Key? key,
    required this.day,
  }) : super(key: key);

  final DateTime day;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, state) => ActionButtonLight(
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
                      BlocProvider(
                        create: (context) =>
                            ActivityWizardCubit(settings: state),
                      ),
                      BlocProvider<EditActivityBloc>(
                        create: (_) => EditActivityBloc.newActivity(
                          activitiesBloc: context.read<ActivitiesBloc>(),
                          clockBloc: context.read<ClockBloc>(),
                          memoplannerSettingBloc:
                              context.read<MemoplannerSettingBloc>(),
                          day: day,
                        ),
                      ),
                    ],
                    child: const ActivityWizardPage(),
                  ),
                ),
              ),
            );
          },
          child: const Icon(AbiliaIcons.plus),
        ),
      );

  bool _canAddActivity(
          BuildContext context, MemoplannerSettingsState settingState) =>
      !settingState.wizardWithOnlyTemplateStep ||
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
