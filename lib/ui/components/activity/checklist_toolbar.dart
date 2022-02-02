import 'package:seagull/ui/all.dart';

enum ChecklistReorderDirection { up, down }

class ChecklistToolbar extends StatelessWidget {
  const ChecklistToolbar({
    Key? key,
    this.disableUp = false,
    this.disableDown = false,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onTapReorder,
  }) : super(key: key);

  final bool disableUp, disableDown;
  final Function() onTapEdit, onTapDelete;
  final Function(ChecklistReorderDirection) onTapReorder;

  @override
  Widget build(BuildContext context) {
    final spacing = 8.s;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: layout.checkList.questionViewPadding,
        decoration: boxDecoration.copyWith(
          color: AbiliaColors.black80,
          border: Border.all(style: BorderStyle.none),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: spacing),
            _ChecklistToolbarButton(
              disabled: disableUp,
              iconData: AbiliaIcons.cursorUp,
              onTap: () => onTapReorder(ChecklistReorderDirection.up),
            ),
            SizedBox(width: spacing),
            _ChecklistToolbarButton(
              key: TestKey.checklistToolbarDeleteQButton,
              iconData: AbiliaIcons.deleteAllClear,
              onTap: onTapDelete,
            ),
            SizedBox(width: spacing),
            _ChecklistToolbarButton(
              key: TestKey.checklistToolbarEditQButton,
              iconData: AbiliaIcons.edit,
              onTap: onTapEdit,
            ),
            SizedBox(width: spacing),
            _ChecklistToolbarButton(
              key: TestKey.checklistToolbarDownButton,
              disabled: disableDown,
              iconData: AbiliaIcons.cursorDown,
              onTap: () => onTapReorder(ChecklistReorderDirection.down),
            ),
            SizedBox(width: spacing),
          ],
        ),
      ),
    );
  }
}

class _ChecklistToolbarButton extends StatelessWidget {
  const _ChecklistToolbarButton({
    Key? key,
    required this.iconData,
    this.disabled = false,
    this.onTap,
  }) : super(key: key);
  final IconData iconData;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: const CircleBorder(side: BorderSide.none),
        onTap: disabled ? null : onTap,
        child: Container(
          height: 40.s,
          width: 40.s,
          decoration: disabled
              ? null
              : BoxDecoration(
                  color: AbiliaColors.transparentWhite20,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AbiliaColors.transparentWhite30,
                    width: 1.s,
                  ),
                ),
          child: Icon(
            iconData,
            color: disabled ? AbiliaColors.white140 : AbiliaColors.white,
            size: 24.s,
          ),
        ),
      ),
    );
  }
}
