import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class ExtraFunctionWiz extends StatelessWidget {
  const ExtraFunctionWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final checklist = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.addActivity.stepByStep.checklist);
    final notes = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.addActivity.stepByStep.notes);
    return WizardScaffold(
      iconData: AbiliaIcons.addAttachment,
      title: Lt.of(context).selectInfoType,
      body: InfoItemTab(
        showChecklist: checklist,
        showNote: notes,
      ),
    );
  }
}
