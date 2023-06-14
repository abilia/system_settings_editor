import 'package:flutter/gestures.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class PermissionInfoDialog extends StatelessWidget {
  final Permission permission;

  const PermissionInfoDialog({
    required this.permission,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocListener<PermissionCubit, PermissionState>(
      listenWhen: (previous, current) =>
          current.status[permission]?.isGranted ?? true,
      listener: (context, state) async => Navigator.of(context).maybePop(),
      child: ViewDialog(
        expanded: true,
        bodyPadding: EdgeInsets.zero,
        backNavigationWidget: const CloseButton(),
        body: Column(
          children: [
            const Spacer(flex: 96),
            Icon(
              permission.iconData,
              size: layout.icon.huge,
            ),
            const Spacer(flex: 64),
            Tts(
              child: Text(
                permission.translate(translate),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: layout.formPadding.verticalItemDistance),
            PermissionInfoBodyText(
              allowAccessBodyText: body(translate),
            ),
            const Spacer(flex: 32),
            Padding(
              padding: layout.templates.m1.onlyHorizontal,
              child: PermissionSwitch(
                permission: permission,
                status: PermissionStatus.permanentlyDenied,
              ),
            ),
            const Spacer(flex: 51),
          ],
        ),
      ),
    );
  }

  String body(Lt translate) {
    if (permission == Permission.camera) return translate.allowAccessCameraBody;
    if (permission == Permission.photos) return translate.allowAccessPhotosBody;
    if (permission == Permission.microphone) {
      return translate.allowAccessMicrophoneBody;
    }
    return '';
  }
}

class PermissionInfoBodyText extends StatelessWidget {
  const PermissionInfoBodyText({
    required this.allowAccessBodyText,
    Key? key,
  }) : super(key: key);

  final String allowAccessBodyText;
  @override
  Widget build(BuildContext context) {
    final bodyMedium = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AbiliaColors.black75);
    final translate = Lt.of(context);
    return Padding(
      padding: layout.templates.m4,
      child: Tts.fromSemantics(
        SemanticsProperties(
          multiline: true,
          label: translate.allowAccess(allowAccessBodyText),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: bodyMedium,
            children: [
              TextSpan(text: '$allowAccessBodyText '),
              TextSpan(text: '${translate.allowAccessBody2} '),
              buildSettingsLinkTextSpan(context),
            ],
          ),
        ),
      ),
    );
  }
}

TextSpan buildSettingsLinkTextSpan(BuildContext context) => TextSpan(
      children: [
        TextSpan(
          text: Lt.of(context).settingsLink,
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final authProviders = copiedAuthProviders(context);
              Navigator.of(context).pop();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: authProviders,
                    child: const PermissionsPage(),
                  ),
                  settings: (PermissionsPage).routeSetting(),
                ),
              );
            },
        ),
        const TextSpan(text: '.'),
      ],
    );
