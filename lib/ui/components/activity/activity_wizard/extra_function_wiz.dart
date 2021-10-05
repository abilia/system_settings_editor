import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class ExtraFunctionWiz extends StatelessWidget {
  const ExtraFunctionWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.add_attachment,
        title: Translator.of(context).translate.selectInfoType,
      ),
      body: InfoItemTab(),
      bottomNavigationBar: WizardBottomNavigation(),
    );
  }
}
