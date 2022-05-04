import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class AddButton extends StatelessWidget {
  const AddButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => TextAndOrIconActionButtonLight(
        Translator.of(context).translate.newActivityButton,
        AbiliaIcons.plus,
        onPressed: () {
          final authProviders = copiedAuthProviders(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: const CreateNewPage(),
              ),
            ),
          );
        },
      );
}
