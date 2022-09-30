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
    final licenseNumberConroller = TextEditingController();
    return MaterialApp(
      theme: abiliaTheme,
      home: Scaffold(
        body: Padding(
          padding: layout.templates.m5,
          child: FutureBuilder<bool>(
            future: SystemSettingsEditor.canWriteSettings,
            builder: (context, writeSettingsSnapshot) {
              return Column(
                children: [
                  MEMOplannerLogo(height: layout.login.logoHeight),
                  SizedBox(height: layout.formPadding.groupHorizontalDistance),
                  Text(
                    'Welcome to the production guide!',
                    style: abiliaTextTheme.headline6,
                  ),
                  const SizedBox(height: 50),
                  InputField(
                    heading: 'Serial number',
                    serialIdController: serialIdController,
                  ),
                  SizedBox(
                    height: layout.formPadding.smallVerticalItemDistance,
                  ),
                  Row(children: [
                    TextButton(
                      onPressed: AndroidIntents.openDeviceInfoSettings,
                      style: greyIconTextButtonStyle,
                      child: Row(
                        children: [
                          Icon(
                            AbiliaIcons.inputSettings,
                            size: layout.icon.button,
                          ),
                          SizedBox(
                            width: layout.formPadding.horizontalItemDistance,
                          ),
                          const Text('Fetch from settings'),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: layout.formPadding.horizontalItemDistance,
                    ),
                    GreyButton(
                      serialIdController: serialIdController,
                      iconData: AbiliaIcons.past,
                      text: 'Paste from clipboard',
                    ),
                  ]),
                  const SizedBox(height: 50),
                  InputField(
                    heading: 'License key',
                    serialIdController: licenseNumberConroller,
                    subHeading:
                        'Enter license key to be connected to this device',
                  ),
                  SizedBox(height: layout.formPadding.largeGroupDistance),
                  SwitchField(
                    value: writeSettingsSnapshot.data ?? false,
                    child: const Text('Write system settings permission'),
                    onChanged: (_) async {
                      await AndroidIntents
                          .openWriteSettingsPermissionSettings();
                    },
                  ),
                  const SizedBox(height: 50),
                  TextButton(
                    onPressed: writeSettingsSnapshot.data ?? false
                        ? () => context
                            .read<StartupCubit>()
                            .verifySerialId(serialIdController.text)
                        : null,
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class GreyButton extends StatelessWidget {
  const GreyButton({
    required this.serialIdController,
    required this.iconData,
    required this.text,
    Key? key,
  }) : super(key: key);

  final TextEditingController serialIdController;
  final String text;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Clipboard.getData(Clipboard.kTextPlain)
          .then((value) => serialIdController.text = value?.text ?? ''),
      style: greyIconTextButtonStyle,
      child: Row(
        children: [
          Icon(
            iconData,
            size: layout.icon.button,
          ),
          SizedBox(
            width: layout.formPadding.horizontalItemDistance,
          ),
          Text(text),
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    required this.heading,
    required this.serialIdController,
    this.subHeading,
    Key? key,
  }) : super(key: key);

  final String heading;
  final TextEditingController serialIdController;
  final String? subHeading;

  @override
  Widget build(BuildContext context) {
    final sub = subHeading;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeading(heading),
        TextField(
          controller: serialIdController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        if (sub != null) SubHeading(sub),
      ],
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
