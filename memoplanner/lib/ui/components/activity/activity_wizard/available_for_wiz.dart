import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

class AvailableForWiz extends StatelessWidget {
  const AvailableForWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocSelector<EditActivityCubit, EditActivityState, Activity>(
      selector: (state) => state.activity,
      builder: (context, activity) {
        final authenticatedState = context.read<AuthenticationBloc>().state;
        if (authenticatedState is! Authenticated) {
          return const SizedBox.shrink();
        }
        return WizardScaffold(
          iconData: AbiliaIcons.unlock,
          title: translate.availableFor,
          body: BlocProvider<AvailableForCubit>(
            create: (context) => AvailableForCubit(
              supportPersonsRepository: SupportPersonsRepository(
                baseUrlDb: GetIt.I<BaseUrlDb>(),
                client: GetIt.I<ListenableClient>(),
                db: GetIt.I<SupportPersonsDb>(),
                userId: authenticatedState.userId,
              ),
              availableFor: activity.availableFor,
              selectedSupportPersons: activity.secretExemptions,
            ),
            child: AvailableForPageBody(
              onAvailableForChanged: (availableFor) => context
                  .read<EditActivityCubit>()
                  .setAvailableFor(availableFor),
              onSupportPersonChanged: (id) =>
                  context.read<EditActivityCubit>().toggleSupportPerson(id),
            ),
          ),
        );
      },
    );
  }
}
