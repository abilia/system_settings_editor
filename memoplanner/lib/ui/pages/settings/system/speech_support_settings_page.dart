import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class SpeechSupportSettingsPage extends StatelessWidget {
  const SpeechSupportSettingsPage({
    required this.textToSpeech,
    required this.speechRate,
    Key? key,
  }) : super(key: key);

  final bool textToSpeech;
  final double speechRate;

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AbiliaColors.black75);
    return WillPopScope(
      onWillPop: () async {
        await _disabledIfNoDownloadedVoice(context);
        return true;
      },
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: t.textToSpeech,
          label: t.system,
          iconData: AbiliaIcons.speakText,
        ),
        body: DividerTheme(
          data: layout.settingsBasePage.dividerThemeData,
          child: BlocBuilder<SpeechSettingsCubit, SpeechSettingsState>(
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextToSpeechSwitch().pad(
                  EdgeInsets.only(
                        bottom: layout.formPadding.groupBottomDistance,
                      ) +
                      layout.templates.m1.onlyHorizontal,
                ),
                if (state.textToSpeech) ...[
                  Divider(height: DividerTheme.of(context).thickness),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tts(
                        child: Text(
                          t.voice,
                          style: textStyle,
                        ),
                      ).pad(
                        EdgeInsets.only(
                          bottom: layout.formPadding.verticalItemDistance,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: BlocSelector<VoicesCubit, VoicesState, bool>(
                              selector: (state) => state.downloading.isNotEmpty,
                              builder: (context, downloadingVoices) =>
                                  PickField(
                                text: Text(state.voice.isEmpty
                                    ? downloadingVoices
                                        ? t.installing
                                        : t.noVoicesInstalled
                                    : state.voice),
                                onTap: () async {
                                  await context
                                      .read<VoicesCubit>()
                                      .loadAvailableVoices();
                                  if (context.mounted) {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const VoicesPage(),
                                        settings: (VoicesPage).routeSetting(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: state.voice.isNotEmpty
                                  ? layout
                                      .formPadding.largeHorizontalItemDistance
                                  : 0,
                            ),
                            child: TtsPlayButton(
                              tts: state.voice.isNotEmpty
                                  ? t.testOfSpeechRate
                                  : '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).pad(
                    EdgeInsets.only(
                          top: layout.formPadding.groupTopDistance,
                          bottom: layout.formPadding.groupBottomDistance,
                        ) +
                        layout.templates.m1.onlyHorizontal,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tts(
                        child: Text(
                          '${t.speechRate} ${_speechRateToProgress(state.speechRate).round()}',
                          style: textStyle,
                        ),
                      ).pad(
                        EdgeInsets.only(
                          bottom: layout.formPadding.verticalItemDistance,
                        ),
                      ),
                      AbiliaSlider(
                        value: _speechRateToProgress(state.speechRate),
                        min: -5,
                        max: 5,
                        leading: const Icon(AbiliaIcons.fastForward),
                        onChanged: state.voice.isEmpty
                            ? null
                            : (v) async => context
                                .read<SpeechSettingsCubit>()
                                .setSpeechRate(_progressToSpeechRate(v)),
                        divisions: 10,
                      ),
                    ],
                  ).pad(
                    EdgeInsets.only(
                          bottom: layout.formPadding.groupBottomDistance,
                        ) +
                        layout.templates.m1.onlyHorizontal,
                  ),
                  Divider(height: DividerTheme.of(context).thickness),
                  SwitchField(
                    onChanged: state.voice.isEmpty
                        ? null
                        : (on) async => context
                            .read<SpeechSettingsCubit>()
                            .setSpeakEveryWord(on),
                    value: state.speakEveryWord,
                    child: Text(t.speakEveryWord),
                  ).pad(
                    EdgeInsets.only(
                          top: layout.formPadding.groupTopDistance,
                        ) +
                        layout.templates.m1.onlyHorizontal,
                  ),
                ],
              ],
            ).pad(layout.templates.m1.onlyTop),
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: CancelButton(
            onPressed: () async {
              final disabled = await _disabledIfNoDownloadedVoice(context);
              if (!disabled && context.mounted) {
                await Future.wait(
                  <Future>[
                    context
                        .read<SpeechSettingsCubit>()
                        .setTextToSpeech(textToSpeech),
                    context
                        .read<SpeechSettingsCubit>()
                        .setSpeechRate(speechRate),
                  ],
                );
              }
              if (context.mounted) await Navigator.of(context).maybePop();
            },
          ),
          forwardNavigationWidget: OkButton(onPressed: () async {
            await _disabledIfNoDownloadedVoice(context);
            if (context.mounted) {
              await Navigator.of(context).maybePop();
            }
          }),
        ),
      ),
    );
  }

  Future<bool> _disabledIfNoDownloadedVoice(BuildContext context) async {
    if (context.read<VoicesCubit>().state.downloaded.isEmpty &&
        context.read<VoicesCubit>().state.downloading.isEmpty) {
      final speechSettingsCubit = context.read<SpeechSettingsCubit>();
      await speechSettingsCubit.setVoice('');
      await speechSettingsCubit.setTextToSpeech(false);
      return true;
    }
    return false;
  }

  double _speechRateToProgress(double speechRate) {
    return ((speechRate - 100) / 10);
  }

  double _progressToSpeechRate(double progress) {
    return 100 + progress * 10;
  }
}
