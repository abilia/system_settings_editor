import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ExtraFunctionWiz extends StatelessWidget {
  const ExtraFunctionWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      iconData: AbiliaIcons.addAttachment,
      title: Translator.of(context).translate.selectInfoType,
      body: BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState,
          StepByStepSettings>(
        selector: (state) => state.settings.stepByStep,
        builder: (context, stepByStep) => InfoItemTab(
          showChecklist: stepByStep.checklist,
          showNote: stepByStep.notes,
        ),
      ),
    );
  }
}
