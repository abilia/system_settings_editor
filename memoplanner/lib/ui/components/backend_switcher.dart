import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

class BackendSwitcherDialog extends StatefulWidget {
  const BackendSwitcherDialog({Key? key}) : super(key: key);

  @override
  State<BackendSwitcherDialog> createState() => _BackendSwitcherDialogState();
}

class _BackendSwitcherDialogState extends State<BackendSwitcherDialog> {
  late final TextEditingController textEditingController;
  @override
  void initState() {
    super.initState();
    textEditingController =
        TextEditingController(text: context.read<BaseUrlCubit>().state);
    textEditingController.addListener(() =>
        context.read<BaseUrlCubit>().updateBaseUrl(textEditingController.text));
  }

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: const AppBarHeading(
        text: 'Switch backend',
        iconData: AbiliaIcons.oneDrive,
      ),
      body: Column(
        children: [
          Wrap(
            spacing: layout.formPadding.verticalItemDistance,
            children: [
              ...backendEnvironments.entries.map(
                (kvp) => Builder(
                  builder: (context) => TextButton(
                    style: kvp.key == context.watch<BaseUrlCubit>().state
                        ? actionButtonStyleLightSelected
                        : actionButtonStyleDark,
                    onPressed: () => textEditingController.text = kvp.key,
                    child: Text(kvp.value),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          TextField(controller: textEditingController),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          const Version(),
        ],
      ),
      backNavigationWidget: OkButton(onPressed: Navigator.of(context).maybePop),
    );
  }
}

class Version extends StatelessWidget {
  const Version({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Tts(child: Text(versionText(GetIt.I<PackageInfo>())));

  static String versionText(PackageInfo packageInfo) =>
      '${packageInfo.version} (${packageInfo.buildNumber})'
      '${Config.dev ? '-dev' : ''}';
}
