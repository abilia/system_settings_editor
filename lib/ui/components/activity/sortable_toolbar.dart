import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SortableToolbar extends StatelessWidget {
  const SortableToolbar({
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onTapReorder,
    this.disableUp = false,
    this.disableDown = false,
    this.margin,
    Key? key,
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
        constraints: const BoxConstraints(minHeight: double.infinity),
        decoration: boxDecoration.copyWith(
          color: AbiliaColors.black80,
          border: Border.all(style: BorderStyle.none),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: spacing),
            SecondaryActionButtonLight(
              child: const Icon(AbiliaIcons.cursorUp),
              onPressed: disableUp
                  ? null
                  : () => onTapReorder(SortableReorderDirection.up),
            ),
            SizedBox(width: spacing),
            SecondaryActionButtonLight(
              child: const Icon(AbiliaIcons.deleteAllClear),
              onPressed: onTapDelete,
            ),
            SizedBox(width: spacing),
            SecondaryActionButtonLight(
              child: const Icon(AbiliaIcons.edit),
              onPressed: onTapEdit,
            ),
            SizedBox(width: spacing),
            SecondaryActionButtonLight(
              child: const Icon(AbiliaIcons.cursorDown),
              onPressed: disableDown
                  ? null
                  : () => onTapReorder(SortableReorderDirection.down),
            ),
            SizedBox(width: spacing),
          ],
        ),
      ),
    );
  }
}
