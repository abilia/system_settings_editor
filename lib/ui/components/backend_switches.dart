import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

class BackendSwitchesDialog extends StatelessWidget {
  const BackendSwitchesDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: const AppBarHeading(
        text: 'Switch backend',
        iconData: AbiliaIcons.oneDrive,
      ),
      body: Column(
        children: [
          BlocBuilder<BaseUrlCubit, String>(
            builder: (context, baseUrl) => Wrap(
              spacing: 8.s,
              children: [
                ...backEndEnvironments.entries.map(
                  (kvp) => BackEndButton(
                    kvp.key,
                    backendUrl: kvp.value,
                    currentBaseUrl: baseUrl,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8.s),
          const Version(),
        ],
      ),
      backNavigationWidget: OkButton(onPressed: Navigator.of(context).maybePop),
    );
  }
}

class BackEndButton extends StatelessWidget {
  const BackEndButton(
    this.text, {
    required this.backendUrl,
    required this.currentBaseUrl,
    Key? key,
  }) : super(key: key);

  final String backendUrl;
  final String text;
  final String currentBaseUrl;

  @override
  Widget build(BuildContext context) {
    onTap() => context.read<BaseUrlCubit>().updateBaseUrl(backendUrl);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24.s,
            child: FittedBox(
              child: Radio(
                groupValue: currentBaseUrl,
                value: backendUrl,
                onChanged: (url) => onTap(),
              ),
            ),
          ),
          Text(text),
        ],
      ),
    );
  }
}
