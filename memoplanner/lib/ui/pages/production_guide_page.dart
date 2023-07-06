import 'dart:async';

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
  final licenseNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeDependencies();
    if (state == AppLifecycleState.resumed) {
      await _checkWriteSettingsPermission();
      setState(() {});
    }
  }

  Future<void> _checkWriteSettingsPermission() async {
    final status = await SystemSettingsEditor.canWriteSettings;
    if (status) {
      await SystemSettingsEditor.setSoundEffectsEnabled(false);
      await SystemSettingsEditor.setHapticFeedbackEnabled(false);
      await SystemSettingsEditor.setScreenOffTimeout(30.minutes());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialAppWrapper(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: layout.templates.m5,
            child: FutureBuilder<bool>(
              future: SystemSettingsEditor.canWriteSettings,
              builder: (context, writeSettingsSnapshot) {
                final canWriteSettings = writeSettingsSnapshot.data ?? false;
                return BlocBuilder<StartupCubit, StartupState>(
                  builder: (context, startupState) =>
                      BlocSelector<PermissionCubit, PermissionState, bool>(
                    selector: (state) =>
                        state.status[Permission.ignoreBatteryOptimizations]
                            ?.isGranted ??
                        false,
                    builder: (context, batteryOptimizationsDisabled) => Column(
                      children: [
                        MEMOplannerLogoHiddenBackendSwitch(
                          loading: startupState is Verifying,
                        ),
                        SizedBox(
                            height: layout.formPadding.groupHorizontalDistance),
                        Text(
                          'Welcome to the production guide!',
                          style: abiliaTextTheme.titleLarge,
                        ),
                        const SizedBox(height: 50),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SubHeading('Serial number'),
                            TextField(
                              controller: serialIdController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: layout.formPadding.smallVerticalItemDistance,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            children: [
                              const IconAndTextButtonDark(
                                icon: AbiliaIcons.inputSettings,
                                text: 'Fetch from settings',
                                onPressed:
                                    AndroidIntents.openDeviceInfoSettings,
                              ),
                              SizedBox(
                                width:
                                    layout.formPadding.horizontalItemDistance,
                              ),
                              IconAndTextButtonDark(
                                  icon: AbiliaIcons.past,
                                  text: 'Paste from clipboard',
                                  onPressed: () async =>
                                      Clipboard.getData(Clipboard.kTextPlain)
                                          .then((value) => serialIdController
                                              .text = value?.text ?? '')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SubHeading('License key'),
                            TextField(
                                controller: licenseNumberController,
                                decoration: licenseInputDecoration(context),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LicenseNumberFormatter(),
                                ]),
                            const SubHeading(
                              'Enter license key to be connected to this device',
                            ),
                          ],
                        ),
                        SizedBox(height: layout.formPadding.largeGroupDistance),
                        if (!canWriteSettings) ...[
                          SwitchField(
                            value: canWriteSettings,
                            child:
                                const Text('Write system settings permission'),
                            onChanged: (_) async {
                              await AndroidIntents
                                  .openWriteSettingsPermissionSettings();
                            },
                          ),
                          const SizedBox(height: 50),
                        ],
                        if (!batteryOptimizationsDisabled) ...[
                          SwitchField(
                            value: batteryOptimizationsDisabled,
                            child: const Text('Disabled battery optimizations'),
                            onChanged: (_) async {
                              await context
                                  .read<PermissionCubit>()
                                  .requestPermissions(
                                      [Permission.ignoreBatteryOptimizations]);
                            },
                          ),
                          const SizedBox(height: 50),
                        ],
                        TextButton(
                          onPressed: canWriteSettings &&
                                  batteryOptimizationsDisabled &&
                                  startupState is! Verifying
                              ? () async =>
                                  context.read<StartupCubit>().verifySerialId(
                                        serialIdController.text,
                                        licenseNumberController.text,
                                      )
                              : null,
                          style: textButtonStyleGreen,
                          child: const Text('Verify'),
                        ),
                        if (startupState is VerifySerialIdFailed)
                          Text(startupState.message),
                        const Spacer(),
                        if (!Config.release)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const AbiliaLogo(),
                              InkWell(
                                onTap: () async => context
                                    .read<StartupCubit>()
                                    .skipProductionGuide(),
                                child: const Text(
                                  'Skip production guide >',
                                  key: TestKey.skipProductionGuide,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration licenseInputDecoration(BuildContext context) => InputDecoration(
      hintText: '0000 0000 0000',
      hintStyle: DefaultTextStyle.of(context).style.copyWith(
            color: AbiliaColors.white140,
          ),
    );
