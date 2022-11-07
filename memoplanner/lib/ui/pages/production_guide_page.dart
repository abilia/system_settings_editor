import 'package:flutter/services.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class ProductionGuidePage extends StatefulWidget {
  const ProductionGuidePage({Key? key}) : super(key: key);

  @override
  State<ProductionGuidePage> createState() => _ProductionGuidePageState();
}

class _ProductionGuidePageState extends State<ProductionGuidePage>
    with WidgetsBindingObserver {
  final serialIdController = TextEditingController();
  final licenseNumberConroller = TextEditingController();

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
      SystemSettingsEditor.setScreenOffTimeout(30.minutes());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: abiliaTheme,
      home: Scaffold(
        body: Padding(
          padding: layout.templates.m5,
          child: FutureBuilder<bool>(
            future: SystemSettingsEditor.canWriteSettings,
            builder: (context, writeSettingsSnapshot) {
              final canWriteSettings = writeSettingsSnapshot.data ?? false;
              return Column(
                children: [
                  GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => const BackendSwitcherDialog(),
                      );
                    },
                    child: MEMOplannerLogo(height: layout.login.logoHeight),
                  ),
                  SizedBox(height: layout.formPadding.groupHorizontalDistance),
                  Text(
                    'Welcome to the production guide!',
                    style: abiliaTextTheme.headline6,
                  ),
                  const SizedBox(height: 50),
                  InputField(
                    heading: 'Serial number',
                    textController: serialIdController,
                  ),
                  SizedBox(
                    height: layout.formPadding.smallVerticalItemDistance,
                  ),
                  Row(children: [
                    const IconAndTextButtonDark(
                      icon: AbiliaIcons.inputSettings,
                      text: 'Fetch from settings',
                      onPressed: AndroidIntents.openDeviceInfoSettings,
                    ),
                    SizedBox(
                      width: layout.formPadding.horizontalItemDistance,
                    ),
                    IconAndTextButtonDark(
                        icon: AbiliaIcons.past,
                        text: 'Paste from clipboard',
                        onPressed: () => Clipboard.getData(Clipboard.kTextPlain)
                            .then((value) =>
                                serialIdController.text = value?.text ?? '')),
                  ]),
                  const SizedBox(height: 50),
                  InputField(
                    heading: 'License key',
                    textController: licenseNumberConroller,
                    subHeading:
                        'Enter license key to be connected to this device',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d -]')),
                    ],
                  ),
                  SizedBox(height: layout.formPadding.largeGroupDistance),
                  if (!canWriteSettings) ...[
                    SwitchField(
                      value: canWriteSettings,
                      child: const Text('Write system settings permission'),
                      onChanged: (_) async {
                        await AndroidIntents
                            .openWriteSettingsPermissionSettings();
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                  TextButton(
                    onPressed: canWriteSettings
                        ? () => context.read<StartupCubit>().verifySerialId(
                              serialIdController.text,
                              licenseNumberConroller.text,
                            )
                        : null,
                    style: textButtonStyleGreen,
                    child: const Text('Verify'),
                  ),
                  BlocBuilder<StartupCubit, StartupState>(
                    builder: (context, productionGuideState) =>
                        productionGuideState is VerifySerialIdFailed
                            ? Text(productionGuideState.message)
                            : const Text(''),
                  ),
                  const Spacer(),
                  if (!Config.release)
                    BlocBuilder<BaseUrlCubit, String>(
                      builder: (context, baseUrl) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const AbiliaLogo(),
                          InkWell(
                            onTap: () => context
                                .read<StartupCubit>()
                                .skipProductionGuide(),
                            child: const Text(
                              'Skip production guide >',
                              key: TestKey.skipProductionGuide,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    required this.heading,
    required this.textController,
    this.subHeading,
    this.keyboardType,
    this.inputFormatters,
    Key? key,
  }) : super(key: key);

  final String heading;
  final TextEditingController textController;
  final String? subHeading;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final sub = subHeading;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeading(heading),
        TextField(
          controller: textController,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        if (sub != null) SubHeading(sub),
      ],
    );
  }
}
