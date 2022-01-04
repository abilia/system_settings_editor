import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, state) => TextAndOrIconActionButtonLight(
          Translator.of(context).translate.newActivityButton,
          AbiliaIcons.plus,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CopiedAuthProviders(
                  blocContext: context,
                  child: const CreateNewPage(),
                ),
              ),
            );
          },
        ),
      );
}