
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/create_new_page.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    Key? key,
  }) : super(key: key);

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
                  child: const CreateNewPage(),
                ),
              ),
            );
          },
          child: const Icon(AbiliaIcons.plus),
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
