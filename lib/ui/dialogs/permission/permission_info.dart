import 'package:flutter/gestures.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PermissionInfoDialog extends StatelessWidget {
  final Permission permission;

  const PermissionInfoDialog({
    Key? key,
    required this.permission,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocListener<PermissionBloc, PermissionState>(
      listenWhen: (previous, current) =>
          current.status[permission]?.isGranted ?? true,
      listener: (context, state) => Navigator.of(context).maybePop(),
      child: ViewDialog(
        expanded: true,
        bodyPadding: EdgeInsets.zero,
        backNavigationWidget: const CloseButton(),
        body: Column(
          children: [
            const Spacer(flex: 96),
            Icon(
              permission.iconData,
              size: hugeIconSize,
            ),
            const Spacer(flex: 64),
            Tts(
              child: Text(
                permission.translate(translate),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: 8.0.s),
            PermissionInfoBodyText(
              allowAccessBodyText: body(translate),
            ),
            const Spacer(flex: 32),
            Padding(
              padding: EdgeInsets.fromLTRB(12.s, 0, 16.s, 0),
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

  String body(Translated translate) {
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
    Key? key,
    required this.allowAccessBodyText,
  }) : super(key: key);

  final String allowAccessBodyText;
  @override
  Widget build(BuildContext context) {
    final bodyText2 = Theme.of(context)
        .textTheme
        .bodyText2
        ?.copyWith(color: AbiliaColors.black75);
    final translate = Translator.of(context).translate;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.s),
      child: Tts.fromSemantics(
        SemanticsProperties(
          multiline: true,
          label: translate.allowAccess(allowAccessBodyText),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: bodyText2,
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
          text: Translator.of(context).translate.settingsLink,
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CopiedAuthProviders(
                    blocContext: context,
                    child: PermissionsPage(),
                  ),
                  settings: RouteSettings(name: 'PermissionPage'),
                ),
              );
            },
        ),
        TextSpan(text: '.'),
      ],
    );
