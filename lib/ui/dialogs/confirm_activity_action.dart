import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

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
      heading: Text(
        title,
        style: theme.textTheme.headline6,
      ),
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

class CheckActivityConfirmDialog extends StatelessWidget {
  final ActivityOccasion activityOccasion;

  const CheckActivityConfirmDialog({
    Key key,
    @required this.activityOccasion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final heading = activityOccasion.isSignedOff
        ? IconHeading(
            icon: AbiliaIcons.handi_uncheck,
            text: translate.uncheck,
          )
        : IconHeading(
            icon: AbiliaIcons.handi_check,
            text: translate.check,
          );
    final bodyText = activityOccasion.isSignedOff
        ? translate.unCheckActivityQuestion
        : translate.checkActivityQuestion;
    return ConfirmDialog(
      onNoPressed: () => Navigator.of(context).maybePop(false),
      onYesPressed: () {
        BlocProvider.of<ActivitiesBloc>(context).add(UpdateActivity(
            activityOccasion.activity.signOff(activityOccasion.day)));
        Navigator.of(context).maybePop(true);
      },
      heading: IconTheme(
        data: Theme.of(context).iconTheme.copyWith(
              color: AbiliaColors.white,
            ),
        child: DefaultTextStyle(
            style: abiliaTextTheme.headline5.copyWith(
              color: AbiliaColors.white,
            ),
            child: heading),
      ),
      bodyText: bodyText,
    );
  }
}

class IconHeading extends StatelessWidget {
  final String text;
  final IconData icon;
  const IconHeading({
    Key key,
    this.text,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        SizedBox(
          width: 8,
        ),
        Text(text)
      ],
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  final VoidCallback onNoPressed;
  final VoidCallback onYesPressed;
  final Widget heading;
  final String bodyText;
  const ConfirmDialog({
    Key key,
    this.heading,
    this.bodyText,
    this.onNoPressed,
    this.onYesPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 68,
                  color: AbiliaColors.black80,
                  child: Center(child: heading),
                ),
                Container(
                  color: AbiliaColors.white110,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 64,
                    ),
                    child: Center(
                        child: Text(
                      bodyText,
                      style: abiliaTextTheme.bodyText1,
                    )),
                  ),
                ),
                Container(
                  color: AbiliaColors.black80,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NoButton(
                          onPressed: onNoPressed,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        YesButton(
                          onPressed: onYesPressed,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NoButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = Theme.of(context);
    final text = translate.no;
    return Expanded(
      child: Tts(
        data: text,
        child: FlatButton.icon(
          height: 64,
          icon: Icon(
            AbiliaIcons.close_program,
            color: AbiliaColors.white,
          ),
          label: Text(
            text,
            style: theme.textTheme.bodyText1
                .copyWith(height: 1, color: AbiliaColors.white),
          ),
          color: AbiliaColors.transparentWhite20,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class YesButton extends StatelessWidget {
  final VoidCallback onPressed;

  const YesButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = Theme.of(context);
    final text = translate.yes;
    return Expanded(
      child: Tts(
        data: text,
        child: FlatButton.icon(
          height: 64,
          icon: Icon(
            AbiliaIcons.ok,
            color: AbiliaColors.white,
          ),
          label: Text(text,
              style: theme.textTheme.bodyText1.copyWith(
                height: 1,
                color: AbiliaColors.white,
              )),
          color: AbiliaColors.green,
          onPressed: onPressed,
        ),
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
        final headingFont =
            abiliaTextTheme.headline5.copyWith(color: AbiliaColors.white);
        final textRenderSize = widget.title.calulcateTextRenderSize(
          constraints: BoxConstraints(
            maxWidth: widget.activityContainerSize.width,
            maxHeight: 0.0,
          ),
          textStyle: headingFont,
        );
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
                        textRenderSize.scaledLineHeight *
                            textRenderSize.numberOfLines -
                        18.0,
                    width: widget.activityContainerSize.width,
                    child: Opacity(
                      opacity: stateChanged ? 0.0 : 1.0,
                      child: Tts(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: headingFont,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.activityContainerPosition.dx,
                    top: widget.activityContainerPosition.dy,
                    width: widget.activityContainerSize.width,
                    height: widget.activityContainerSize.height,
                    child: ActivityContainer(
                      activityDay: activityOccasion,
                      preview: true,
                    ),
                  ),
                  if (!stateChanged)
                    Positioned(
                      left: widget.activityContainerPosition.dx,
                      top: widget.activityContainerPosition.dy +
                          widget.activityContainerSize.height +
                          10.0,
                      width: widget.activityContainerSize.width,
                      child: BottomCheckRow(
                        activityOccasion: activityOccasion,
                        checkButtonPressed: () async {
                          setState(() => stateChanged = true);
                          BlocProvider.of<ActivitiesBloc>(context).add(
                              UpdateActivity(activityOccasion.activity
                                  .signOff(activityOccasion.day)));
                          await Future.delayed(
                              1.seconds(), Navigator.of(context).maybePop);
                        },
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
        Flexible(
          child: CancelButton(
            key: TestKey.checkDialogCancelButton,
            iconData: AbiliaIcons.close_program,
            text: translate.cancel,
            onPressed: () async {
              await Navigator.of(context).maybePop();
            },
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: CheckitButton(
            key: activityOccasion.isSignedOff
                ? TestKey.checkDialogUncheckButton
                : TestKey.checkDialogCheckButton,
            activityOccasion: activityOccasion,
            onPressed: checkButtonPressed,
          ),
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
      child: FlatButton.icon(
        icon: Icon(
            signedOff ? AbiliaIcons.handi_uncheck : AbiliaIcons.handi_check),
        label: Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyText1.copyWith(height: 1),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        color: signedOff ? AbiliaColors.white : AbiliaColors.green,
        onPressed: onPressed,
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
          label: Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodyText1.copyWith(
                height: 1,
                color: AbiliaColors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          color: AbiliaColors.black60,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
