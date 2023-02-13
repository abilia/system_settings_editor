import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class AvailableForWiz extends StatelessWidget {
  const AvailableForWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final activity = context.select((EditActivityCubit c) => c.state.activity);
    final authenticatedState = context.read<AuthenticationBloc>().state;
    if (authenticatedState is! Authenticated) {
      return const SizedBox.shrink();
    }
    return WizardScaffold(
      iconData: AbiliaIcons.unlock,
      title: translate.availableFor,
      body: BlocProvider<AvailableForCubit>(
        create: (context) => AvailableForCubit(
          supportPersonsCubit: context.read<SupportPersonsCubit>(),
          availableFor: activity.availableFor,
          selectedSupportPersons: activity.secretExemptions,
        )..setSupportPersonsStream(),
        child: AvailableForPageBody(
          onAvailableForChanged: (availableFor) =>
              context.read<EditActivityCubit>().setAvailableFor(availableFor),
          onSupportPersonChanged: (id) =>
              context.read<EditActivityCubit>().toggleSupportPerson(id),
        ),
      ),
    );
  }
}
