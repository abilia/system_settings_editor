import 'package:seagull/bloc/all.dart';
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
}
