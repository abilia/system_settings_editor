import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class ConfirmActivityActionDialog extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final String title;
  final String extraMessage;

  const ConfirmActivityActionDialog({
    Key key,
    @required this.activityOccasion,
    @required this.title,
    this.extraMessage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = abiliaTheme;
    return ViewDialog(
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

class ConfirmCheckDialogOverlay extends StatefulWidget {
  final ActivityOccasion occasion;
  final String title;
  final Size activityContainerSize;
  final Offset activityContainerPosition;

  const ConfirmCheckDialogOverlay({
    Key key,
    @required this.title,
    @required this.occasion,
    @required this.activityContainerSize,
    @required this.activityContainerPosition,
  }) : super(key: key);

  @override
  _ConfirmCheckDialogOverlayState createState() =>
      _ConfirmCheckDialogOverlayState();
}

class _ConfirmCheckDialogOverlayState extends State<ConfirmCheckDialogOverlay> {
  bool stateChanged = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final activityOccasion = widget.occasion.fromActivitiesState(state);
        final headingPadding = 18.0;
        final headingFont = abiliaTextTheme.headline5;
        final headingHeight = headingFont.fontSize;
        final theme = activityOccasion.isSignedOff
            ? Theme.of(context).copyWith(
                buttonTheme: uncheckButtonThemeData,
                buttonColor: AbiliaColors.transparentBlack20,
              )
            : Theme.of(context).copyWith(
                buttonTheme: checkButtonThemeData,
                buttonColor: AbiliaColors.green,
              );
        return AnimatedTheme(
          data: theme,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: widget.activityContainerPosition.dx,
                    top: widget.activityContainerPosition.dy -
                        headingPadding -
                        headingHeight,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Opacity(
                            opacity: stateChanged ? 0.0 : 1.0,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: headingPadding),
                              child: Center(
                                child: Text(
                                  widget.title,
                                  style: abiliaTextTheme.headline5
                                      .copyWith(color: AbiliaColors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: widget.activityContainerSize.height,
                            width: widget.activityContainerSize.width,
                            child: ActivityContainer(
                              activityDay: activityOccasion,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (!stateChanged)
                            BottomCheckRow(
                              activityOccasion: activityOccasion,
                              checkButtonPressed: () async {
                                setState(() {
                                  stateChanged = true;
                                });
                                BlocProvider.of<ActivitiesBloc>(context).add(
                                    UpdateActivity(activityOccasion.activity
                                        .signOff(activityOccasion.day)));
                                await Future.delayed(1.seconds(), () async {
                                  await Navigator.of(context).maybePop();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BottomCheckRow extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final VoidCallback checkButtonPressed;

  const BottomCheckRow({
    Key key,
    @required this.activityOccasion,
    @required this.checkButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CancelButton(
          key: TestKey.checkDialogCancelButton,
          iconData: AbiliaIcons.close_program,
          text: translate.cancel,
          onPressed: () async {
            await Navigator.of(context).maybePop();
          },
        ),
        SizedBox(
          width: 16,
        ),
        CheckitButton(
          key: activityOccasion.isSignedOff
              ? TestKey.checkDialogUncheckButton
              : TestKey.checkDialogCheckButton,
          activityOccasion: activityOccasion,
          onPressed: checkButtonPressed,
        ),
      ],
    );
  }
}

class CheckitButton extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final VoidCallback onPressed;

  const CheckitButton({
    Key key,
    this.onPressed,
    @required this.activityOccasion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;
    final signedOff = activityOccasion.isSignedOff;
    final text = signedOff ? translate.uncheck : translate.check;
    return Tts(
      data: text,
      child: Container(
        child: FlatButton.icon(
          icon: Icon(
              signedOff ? AbiliaIcons.handi_uncheck : AbiliaIcons.handi_check),
          label: Text(
            text,
            style: theme.textTheme.bodyText1.copyWith(height: 1),
          ),
          color: signedOff ? AbiliaColors.white : AbiliaColors.green,
          onPressed: onPressed,
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
          icon: Icon(
            iconData,
            color: AbiliaColors.white,
          ),
          label: Text(
            text,
            style: theme.textTheme.bodyText1.copyWith(
              height: 1,
              color: AbiliaColors.white,
            ),
          ),
          color: AbiliaColors.black60,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
