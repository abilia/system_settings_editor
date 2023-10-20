import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class SortableToolbar extends StatelessWidget {
  const SortableToolbar({
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onTapReorder,
    this.disableUp = false,
    this.disableDown = false,
    this.margin,
    super.key,
  });

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
              onPressed: disableUp
                  ? null
                  : () => onTapReorder(SortableReorderDirection.up),
              child: const Icon(AbiliaIcons.cursorUp),
            ),
            SizedBox(width: spacing),
            SecondaryActionButtonLight(
              onPressed: onTapDelete,
              child: const Icon(AbiliaIcons.deleteAllClear),
            ),
            SizedBox(width: spacing),
            SecondaryActionButtonLight(
              onPressed: onTapEdit,
              child: const Icon(AbiliaIcons.edit),
            ),
            SizedBox(width: spacing),
            SecondaryActionButtonLight(
              onPressed: disableDown
                  ? null
                  : () => onTapReorder(SortableReorderDirection.down),
              child: const Icon(AbiliaIcons.cursorDown),
            ),
            SizedBox(width: spacing),
          ],
        ),
      ),
    );
  }
}
