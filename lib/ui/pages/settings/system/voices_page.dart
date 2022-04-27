import 'package:acapela_tts/acapela_tts.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/speech_support/voice_data.dart';
import 'package:seagull/ui/all.dart';

class VoicesPage extends StatefulWidget {
  final AcapelaTts acapelaTts;

  const VoicesPage({Key? key, required this.acapelaTts}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VoicesPageState();
  }
}

class VoicesPageState extends State<VoicesPage> {
  List<String>? _downloadedVoices;
  String? downloadingVoice;

  @override
  void initState() {
    super.initState();
    loadVoices();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: t.textToSpeech,
        label: t.system,
        iconData: AbiliaIcons.handiAlarmVibration,
      ),
      body: BlocBuilder<SpeechSupportCubit, SpeechSupportState>(
        builder: (context, state) => ListView(
          children: state.voices.map((VoiceData voice) {
            final name = voice.name;
            return VoiceRow(
              selected: name == state.selectedVoice.name,
              voice: voice,
              downloaded: _downloadedVoices?.contains(name) ?? false,
              downloading: downloadingVoice != null && downloadingVoice == name,
              selectedVoice: state.selectedVoice.name,
              keep: _downloadedVoices?.length == 1 &&
                  _downloadedVoices?.first == name,
            );
          }).toList(),
        ).pad(layout.speechSupportPage.bottomPadding),
      ),
      bottomNavigationBar:
          const BottomNavigation(backNavigationWidget: CloseButton()),
    );
  }

  Future<void> loadVoices() async {
    final List<Object?>? voices = await widget.acapelaTts.availableVoices;

    setState(() {
      if (voices != null) {
        _downloadedVoices = (voices.map((e) => e.toString())).toList();
      }
    });
  }

  void onDownloadVoice(String voice) {
    setState(() {
      downloadingVoice = voice;
    });
  }

}

class VoiceRow extends StatelessWidget {
  final bool keep;
  final bool selected;
  final bool downloaded;
  final bool downloading;
  final VoiceData voice;
  final String selectedVoice;

  const VoiceRow({
    Key? key,
    this.keep = false,
    required this.selected,
    required this.voice,
    this.downloaded = false,
    this.downloading = false,
    required this.selectedVoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            child: downloaded
                ? RadioField<String>(
                    groupValue: selectedVoice,
                    onChanged: (name) {
                      if (downloaded && name != null && !selected) {
                        context.read<SpeechSupportCubit>().selectVoice(voice);
                      }
                    },
                    value: voice.name,
                    text: Text('${voice.name}: ${_bytesToMegaBytes(voice.size)}MB '),
                  )
                : DisabledVoiceRow(name: voice.name),
        ),
        CollapsableWidget(
          axis: Axis.horizontal,
          collapsed: !downloading && !downloaded,
          child: Padding(
            padding: EdgeInsets.only(
              left: layout.formPadding.largeHorizontalItemDistance,
            ),
            child: DeleteButton(
              voice: voice,
              enabled: !keep,
            ).pad(layout.speechSupportPage.actionButtonPadding),
          ),
        ),
        CollapsableWidget(
          axis: Axis.horizontal,
          collapsed: !downloading && downloaded,
          child: Padding(
            padding: EdgeInsets.only(
              left: layout.formPadding.largeHorizontalItemDistance,
            ),
            child: downloading
                ? const CircularProgressIndicator()
                    .pad(layout.speechSupportPage.actionButtonPadding)
                : IconActionButtonDark(
                    child: const Icon(AbiliaIcons.download),
                    onPressed: () =>
                        context.read<SpeechSupportCubit>().downloadVoice(voice),
                  ).pad(layout.speechSupportPage.actionButtonPadding),
          ),
        ),
      ],
    ).pad(layout.speechSupportPage.voiceRowPadding);
  }

  int _bytesToMegaBytes(int bytes){
    return bytes ~/ 1048576;
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({Key? key, required this.voice, this.enabled = true})
      : super(key: key);

  final VoiceData voice;
  final bool enabled;

  @override
  Widget build(BuildContext context) => enabled
      ? IconActionButtonDark(
          onPressed: () =>
              context.read<SpeechSupportCubit>().deleteVoice(voice),
          child: const Icon(AbiliaIcons.deleteAllClear),
        )
      : const IconActionButtonLight(child: Icon(AbiliaIcons.deleteAllClear));
}

class DisabledVoiceRow extends StatelessWidget {

  final String name;

  const DisabledVoiceRow({Key? key, required this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.pickField.height,
      decoration: whiteBoxDecoration,
      padding: layout.speechSupportPage.defaultPadding,
      child: DefaultTextStyle(
        style: (Theme.of(context).textTheme.bodyText1 ?? bodyText1)
            .copyWith(height: 1.0),
        child: Text(name),
      ).align(Alignment.centerLeft),
    );
  }

}
