import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/settings/settings_cubit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/dialogs/all.dart';
import 'package:seagull/ui/themes/layout.dart';

class TextToSpeechSwitch extends StatelessWidget {
  const TextToSpeechSwitch({Key? key, this.onChanged, this.immediate = true})
      : super(key: key);

  final Function(bool)? onChanged;
  final bool immediate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) => Row(children: [
        Expanded(
          child: SwitchField(
            value: settingsState.textToSpeech,
            leading: const Icon(AbiliaIcons.speakText),
            onChanged: onChanged ??
                (v) {
                  context.read<SettingsCubit>().setTextToSpeech(v);
                  if (immediate) context.read<SettingsCubit>().save();
                },
            child: Text(Translator.of(context).translate.textToSpeech),
          ),
        ),
        Padding(
          padding: layout.settings.textToSpeechPadding,
          child: InfoButton(
            onTap: () => showViewDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => const LongPressInfoDialog(),
            ),
          ),
        ),
      ]),
    );
  }
}
