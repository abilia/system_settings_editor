import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ConfirmActivityActionDialog extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final String title;
  final String extraMessage;
  final bool overlayStyle;

  const ConfirmActivityActionDialog({
    Key key,
    @required this.activityOccasion,
    @required this.title,
    this.extraMessage,
    this.overlayStyle = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = abiliaTheme;
    return overlayStyle
        ? ConfirmCheckDialog(
            title: title,
            child: SizedBox(
              height: 365,
              width: double.infinity,
              child: ActivityContainer(
                activityDay: activityOccasion,
              ),
            ),
          )
        : ViewDialog(
            heading: Text(title, style: theme.textTheme.headline6),
            onOk: () => Navigator.of(context).maybePop(true),
            child: Column(
              children: [
                ActivityCard(
                  activityOccasion: activityOccasion,
                  preview: true,
                ),
                if (extraMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Tts(child: Text(extraMessage)),
                    ),
                  ),
              ],
            ),
          );
  }
}

class ConfirmCheckDialog extends StatelessWidget {
  final Widget child;
  final String title;

  const ConfirmCheckDialog({
    Key key,
    @required this.child,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(52.0, 110, 12, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: Text(
                    title,
                    style: abiliaTextTheme.headline5
                        .copyWith(color: AbiliaColors.white),
                  ),
                ),
              ),
              child,
              BottomCheckRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomCheckRow extends StatelessWidget {
  const BottomCheckRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CancelButton(
          iconData: AbiliaIcons.close_program,
          text: 'Cancel',
          onPressed: () async {},
        ),
        CheckitButton(
          iconData: AbiliaIcons.handi_check,
          text: 'What?',
          onPressed: () async {},
        ),
      ],
    );
  }
}

class CheckitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final String text;

  const CheckitButton({Key key, this.onPressed, this.iconData, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tts(
      data: text,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: borderRadius,
          ),
          child: FlatButton.icon(
            icon: Icon(iconData),
            label: Text(
              text,
              style: theme.textTheme.bodyText1.copyWith(height: 1),
            ),
            color: theme.buttonColor,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final String text;

  const CancelButton({Key key, this.onPressed, this.iconData, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tts(
      data: text,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: borderRadius,
        ),
        child: FlatButton.icon(
          icon: Icon(iconData),
          label: Text(
            text,
            style: theme.textTheme.bodyText1.copyWith(height: 1),
          ),
          color: theme.buttonColor,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
