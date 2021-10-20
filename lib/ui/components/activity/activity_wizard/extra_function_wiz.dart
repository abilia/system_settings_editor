import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class ExtraFunctionWiz extends StatelessWidget {
  const ExtraFunctionWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.add_attachment,
        title: Translator.of(context).translate.selectInfoType,
        label: Translator.of(context).translate.newActivity,
      ),
      body: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.wizardChecklistStep != current.wizardChecklistStep ||
            previous.wizardNotesStep != current.wizardNotesStep,
        builder: (context, state) => InfoItemTab(
          showChecklist: state.wizardChecklistStep,
          showNote: state.wizardNotesStep,
        ),
      ),
      bottomNavigationBar: const WizardBottomNavigation(),
    );
  }
}
