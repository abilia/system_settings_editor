import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/db/support_persons_db.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/repository/data_repository/support_persons_repository.dart';
import 'package:seagull/ui/all.dart';

class AvailableForWiz extends StatelessWidget {
  const AvailableForWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) => WizardScaffold(
        iconData: AbiliaIcons.unlock,
        title: translate.availableFor,
        body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, authState) =>
              RepositoryProvider<SupportPersonsRepository>(
            create: (context) => SupportPersonsRepository(
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              client: GetIt.I<BaseClient>(),
              db: SupportPersonsDb(GetIt.I<Database>()),
              userId: (authState as Authenticated).userId,
            ),
            child: BlocProvider<AvailableForCubit>(
              create: (context) => AvailableForCubit(
                supportPersonsRepository:
                    context.read<SupportPersonsRepository>(),
                availableFor: state.activity.availableFor,
                selectedSupportPersons: state.activity.secretExemptions,
              ),
              child: AvailableForPageBody(
                onRadioButtonChanged: _onSelected,
                onSupportPersonChanged: _onSupportPersonChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSelected(BuildContext context, AvailableForType? availableFor) {
    if (availableFor != null) {
      final activity = context.read<EditActivityCubit>().state.activity;
      context.read<EditActivityCubit>().replaceActivity(activity.copyWith(
          secret: availableFor != AvailableForType.allSupportPersons,
          secretExemptions:
              availableFor != AvailableForType.selectedSupportPersons
                  ? []
                  : null));
    }
  }

  void _onSupportPersonChanged(BuildContext context, int id, bool selected) {
    final activity = context.read<EditActivityCubit>().state.activity;
    if (selected && !activity.secretExemptions.contains(id)) {
      context.read<EditActivityCubit>().replaceActivity(activity.copyWith(
          secretExemptions: List.from(activity.secretExemptions)..add(id)));
    } else if (!selected && activity.secretExemptions.contains(id)) {
      context.read<EditActivityCubit>().replaceActivity(activity.copyWith(
          secretExemptions: List.from(activity.secretExemptions)..remove(id)));
    }
  }
}
