import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/repository/data_repository/support_persons_repository.dart';
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
            client: GetIt.I<BaseClient>(),
            db: SupportPersonsDb(GetIt.I<SharedPreferences>()),
            userId: authenticatedState.userId,
          ),
          availableFor: activity.availableFor,
          selectedSupportPersons: activity.secretExemptions,
        ),
        child: AvailableForPageBody(
          onRadioButtonChanged: _onSelected,
          onSupportPersonChanged: _onSupportPersonChanged,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _onSelected(BuildContext context, AvailableForType? availableFor) {
    if (availableFor != null) {
      final editActivityCubit = context.read<EditActivityCubit>();
      final activity = editActivityCubit.state.activity;
      editActivityCubit.replaceActivity(activity.copyWith(
          secret: availableFor != AvailableForType.allSupportPersons,
          secretExemptions:
              availableFor != AvailableForType.selectedSupportPersons
                  ? []
                  : null));
    }
  }

  void _onSupportPersonChanged(BuildContext context, int id, bool selected) {
    final editActivityCubit = context.read<EditActivityCubit>();
    final activity = editActivityCubit.state.activity;
    if (selected && !activity.secretExemptions.contains(id)) {
      editActivityCubit.replaceActivity(activity.copyWith(
          secretExemptions: List.from(activity.secretExemptions)..add(id)));
    } else if (!selected && activity.secretExemptions.contains(id)) {
      editActivityCubit.replaceActivity(activity.copyWith(
          secretExemptions: List.from(activity.secretExemptions)..remove(id)));
    }
  }
}
