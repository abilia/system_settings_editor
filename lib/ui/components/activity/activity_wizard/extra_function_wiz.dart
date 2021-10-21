import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class ExtraFunctionWiz extends StatelessWidget {
  const ExtraFunctionWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      iconData: AbiliaIcons.addAttachment,
      title: Translator.of(context).translate.selectInfoType,
      body: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.wizardChecklistStep != current.wizardChecklistStep ||
            previous.wizardNotesStep != current.wizardNotesStep,
        builder: (context, state) => InfoItemTab(
          showChecklist: state.wizardChecklistStep,
          showNote: state.wizardNotesStep,
        ),
      ),
    );
  }
}
