import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/speech_support/voice_data.dart';
import 'package:seagull/ui/all.dart';

class VoicesPage extends StatelessWidget {
  final String initialSelection;

  const VoicesPage({Key? key, required this.initialSelection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<VoicesCubit, VoicesState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          title: t.textToSpeech,
          label: t.system,
          iconData: AbiliaIcons.handiAlarmVibration,
        ),
        body: ListView(
          children: state.voices.map((VoiceData voice) {
            final name = voice.name;
            return _VoiceRow(
              selected: name == state.selectedVoice,
              voice: voice,
              downloaded: state.downloadedVoices.contains(name),
              downloading: state.downloadingVoice == name,
              selectedVoice: state.selectedVoice,
              keep: state.downloadedVoices.length == 1 &&
                  state.downloadedVoices.first == name,
              firstSelection: initialSelection.isEmpty,
            );
          }).toList(),
        ).pad(layout.speechSupportPage.bottomPadding),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: const CloseButton(),
          forwardNavigationWidget: state.selectedVoice != initialSelection
              ? SaveButton(
                  onPressed: () =>
                      Navigator.of(context).pop(state.selectedVoice),
                )
              : null,
        ),
      ),
    );
  }
}

class _VoiceRow extends StatelessWidget {
  final bool keep;
  final bool selected;
  final bool downloaded;
  final bool downloading;
  final VoiceData voice;
  final String selectedVoice;
  final bool firstSelection;

  const _VoiceRow({
    Key? key,
    this.keep = false,
    required this.selected,
    required this.voice,
    this.downloaded = false,
    this.downloading = false,
    required this.selectedVoice,
    required this.firstSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SpeechSupportPageLayout pageLayout = layout.speechSupportPage;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: downloaded
              ? RadioField<String>(
                  groupValue: selectedVoice,
                  onChanged: (name) {
                    if (downloaded && name != null && !selected) {
                      context.read<VoicesCubit>().selectVoice(voice);
                    }
                  },
                  value: voice.name,
                  text: Text('${voice.name}: ${voice.size}MB'),
                )
              : _DisabledVoiceRow(name: '${voice.name}: ${voice.size}MB'),
        ),
        CollapsableWidget(
          axis: Axis.horizontal,
          collapsed: downloaded,
          child: Padding(
            padding: EdgeInsets.only(
              left: layout.formPadding.largeHorizontalItemDistance,
            ),
            child: downloading
                ? SizedBox(
                    width: layout.actionButton.size,
                    height: layout.actionButton.size,
                    child: CircularProgressIndicator(
                            strokeWidth: pageLayout.loaderStrokeWidth,
                            color: AbiliaColors.red)
                        .pad(pageLayout.loaderPadding),
                  ).pad(pageLayout.buttonPadding)
                : IconActionButtonDark(
                    child: const Icon(AbiliaIcons.download),
                    onPressed: () =>
                        context.read<VoicesCubit>().downloadVoice(voice),
                  ).pad(pageLayout.buttonPadding),
          ),
        ),
        CollapsableWidget(
          axis: Axis.horizontal,
          collapsed: downloading || !downloaded || firstSelection,
          child: Padding(
            padding: EdgeInsets.only(
              left: layout.formPadding.largeHorizontalItemDistance,
            ),
            child: _DeleteButton(
              voice: voice,
              enabled: !keep,
            ).pad(pageLayout.buttonPadding),
          ),
        ),
      ],
    ).pad(pageLayout.voiceRowPadding);
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({Key? key, required this.voice, this.enabled = true})
      : super(key: key);

  final VoiceData voice;
  final bool enabled;

  @override
  Widget build(BuildContext context) => enabled
      ? IconActionButtonDark(
          onPressed: () => context.read<VoicesCubit>().deleteVoice(voice),
          child: const Icon(AbiliaIcons.deleteAllClear),
        )
      : const IconActionButtonLight(child: Icon(AbiliaIcons.deleteAllClear));
}

class _DisabledVoiceRow extends StatelessWidget {
  final String name;

  const _DisabledVoiceRow({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.pickField.height,
      decoration: whiteBoxDecoration,
      padding: layout.speechSupportPage.buttonPadding,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyText1 ?? bodyText1,
        child: Text(name),
      ).align(Alignment.centerLeft),
    );
  }
}
