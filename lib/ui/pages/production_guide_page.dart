import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class ProductionGuidePage extends StatefulWidget {
  const ProductionGuidePage({Key? key}) : super(key: key);

  @override
  State<ProductionGuidePage> createState() => _ProductionGuidePageState();
}

class _ProductionGuidePageState extends State<ProductionGuidePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeDependencies();
    if (state == AppLifecycleState.resumed) {
      _checkWriteSettingsPermission();
      setState(() {});
    }
  }

  Future<void> _checkWriteSettingsPermission() async {
    final status = await SystemSettingsEditor.canWriteSettings;
    if (status) {
      SystemSettingsEditor.setSoundEffectsEnabled(false);
      SystemSettingsEditor.setHapticFeedbackEnabled(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serialIdController = TextEditingController();
    return MaterialApp(
      theme: abiliaTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: FutureBuilder(
              future: SystemSettingsEditor.canWriteSettings,
              builder: (context, writeSettingsSnapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _FancyHeader(
                        text: 'Welcome to the production guide!'),
                    const SizedBox(height: 50),
                    const _DebugRow(),
                    const SizedBox(height: 50),
                    if (writeSettingsSnapshot.data != true)
                      TextButton(
                        onPressed:
                            AndroidIntents.openWriteSettingsPermissionSettings,
                        style: textButtonStyleDarkGrey,
                        child: const Text('Grant Write Settings permission'),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: serialIdController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Serial number',
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ElevatedButton(
                                  onPressed:
                                      AndroidIntents.openDeviceInfoSettings,
                                  child: Text('Fetch from settings')),
                              ElevatedButton(
                                  onPressed: () =>
                                      Clipboard.getData(Clipboard.kTextPlain)
                                          .then((value) => serialIdController
                                              .text = value?.text ?? ''),
                                  child: const Text('Paste from clipboard')),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 50),
                      TextButton(
                        onPressed: () => context
                            .read<StartupCubit>()
                            .verifySerialId(serialIdController.text),
                        style: textButtonStyleGreen,
                        child: const Text('Verify'),
                      ),
                      BlocBuilder<StartupCubit, StartupState>(
                        builder: (context, productionGuideState) =>
                            productionGuideState is VerifySerialIdFailed
                                ? Text(productionGuideState.message)
                                : const Text(''),
                      )
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  const _DebugRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseUrlCubit, String>(
      builder: (context, baseUrl) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!Config.release)
            ElevatedButton(
                    onPressed: () =>
                        context.read<StartupCubit>().skipProductionGuide(),
                    child: const Text('Skip production guide'))
                .pad(const EdgeInsets.only(right: 20)),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BackendSwitcherDialog(),
              );
            },
            child: Text(
              'Switch backend (${backendName(baseUrl)})',
            ),
          )
        ],
      ),
    );
  }
}

class _FancyHeader extends StatelessWidget {
  const _FancyHeader({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: 40,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.blue[700]!,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 40,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}
