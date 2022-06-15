import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/repository/data_repository/support_persons_repository.dart';
import 'package:seagull/repository/http_client.dart';
import 'package:seagull/ui/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvailableForWiz extends StatelessWidget {
  const AvailableForWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) => WizardScaffold(
        iconData: AbiliaIcons.unlock,
        title: translate.availableFor,
        body: getAvailableForContext(context, state.activity),
      ),
    );
  }

  Widget getAvailableForContext(BuildContext context, Activity activity) {
    final authenticatedState = context.read<AuthenticationBloc>().state;
    if (authenticatedState is Authenticated) {
      return BlocProvider<AvailableForCubit>(
        create: (context) => AvailableForCubit(
          supportPersonsRepository: SupportPersonsRepository(
            baseUrlDb: GetIt.I<BaseUrlDb>(),
            client: GetIt.I<ListenableClient>(),
            db: SupportPersonsDb(GetIt.I<SharedPreferences>()),
            userId: authenticatedState.userId,
          ),
          availableFor: activity.availableFor,
          selectedSupportPersons: activity.secretExemptions,
        ),
        child: AvailableForPageBody(
          onAvailableForChanged: (availableFor) =>
              context.read<EditActivityCubit>().setAvailableFor(availableFor),
          onSupportPersonChanged: (id) =>
              context.read<EditActivityCubit>().supportPersonChanged(id),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
