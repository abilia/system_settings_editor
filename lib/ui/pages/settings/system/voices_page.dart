import 'package:seagull/bloc/all.dart';
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
        body: Padding(
          padding: layout.settingsBasePage.listPadding,
          child: Column(
            children: state.voices.map((VoiceData voice) {
              final name = voice.name;
              return _VoiceRow(
                selected: name == state.selectedVoice,
                voice: voice,
                downloaded: state.downloadedVoices.contains(name),
                downloading: state.downloadingVoices.contains(name),
                selectedVoice: state.selectedVoice,
                keep: state.downloadedVoices.length == 1 &&
                    state.downloadedVoices.first == name,
                firstSelection: initialSelection.isEmpty,
              );
            }).toList(),
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: OkButton(
            onPressed: () => Navigator.of(context).pop(state.selectedVoice),
          ),
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
    return Padding(
      padding: layout.settingsBasePage.itemPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
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
                        valueColor:
                            const AlwaysStoppedAnimation(AbiliaColors.red),
                      ).pad(pageLayout.loaderPadding),
                    )
                  : IconActionButtonDark(
                      child: const Icon(AbiliaIcons.download),
                      onPressed: () async => await context
                          .read<VoicesCubit>()
                          .downloadVoice(voice),
                    ),
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
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: layout.formPadding.largeHorizontalItemDistance,
              ),
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
          ),
        ],
      ),
    );
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
      padding: EdgeInsets.only(
        left: layout.formPadding.largeHorizontalItemDistance,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText1 ?? bodyText1,
          child: Text(name),
        ),
      ),
    );
  }
}
