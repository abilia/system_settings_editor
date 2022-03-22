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
              spacing: layout.formPadding.verticalItemDistance,
              children: [
                ...backendEnvironments.entries.map(
                  (kvp) => BackendButton(
                    kvp.value,
                    backendUrl: kvp.key,
                    currentBaseUrl: baseUrl,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          const Version(),
        ],
      ),
      backNavigationWidget: OkButton(onPressed: Navigator.of(context).maybePop),
    );
  }
}

class BackendButton extends StatelessWidget {
  const BackendButton(
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
            height: layout.formPadding.dividerBottomDistance,
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
