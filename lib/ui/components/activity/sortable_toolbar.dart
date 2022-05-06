import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SortableToolbar extends StatelessWidget {
  const SortableToolbar({
    Key? key,
    this.disableUp = false,
    this.disableDown = false,
    this.margin,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onTapReorder,
  }) : super(key: key);

  final bool disableUp, disableDown;
  final void Function()? onTapEdit, onTapDelete;
  final Function(SortableReorderDirection) onTapReorder;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final spacing = layout.formPadding.horizontalItemDistance;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: margin,
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
              onTap: () => onTapReorder(SortableReorderDirection.up),
            ),
            SizedBox(width: spacing),
            _ChecklistToolbarButton(
              iconData: AbiliaIcons.deleteAllClear,
              onTap: onTapDelete,
            ),
            SizedBox(width: spacing),
            _ChecklistToolbarButton(
              iconData: AbiliaIcons.edit,
              onTap: onTapEdit,
            ),
            SizedBox(width: spacing),
            _ChecklistToolbarButton(
              disabled: disableDown,
              iconData: AbiliaIcons.cursorDown,
              onTap: () => onTapReorder(SortableReorderDirection.down),
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
          height: layout.checkList.toolbarButtonSize,
          width: layout.checkList.toolbarButtonSize,
          decoration: disabled
              ? null
              : BoxDecoration(
                  color: AbiliaColors.transparentWhite20,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AbiliaColors.transparentWhite30,
                    width: layout.borders.thin,
                  ),
                ),
          child: Icon(
            iconData,
            color: disabled ? AbiliaColors.white140 : AbiliaColors.white,
            size: layout.icon.small,
          ),
        ),
      ),
    );
  }
}
