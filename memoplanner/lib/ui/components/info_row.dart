import 'package:memoplanner/ui/all.dart';

enum InfoRowState {
  critical,
  criticalLoading,
  normal,
  verified;
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.state,
    required this.icon,
    required this.title,
    this.padding,
    this.textColor,
    super.key,
  });

  final InfoRowState state;
  final IconData icon;
  final String title;
  final EdgeInsets? padding;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? layout.infoRow.contentPadding,
      decoration: BoxDecoration(
        border: Border.all(
          width: layout.infoRow.borderWidth,
          strokeAlign: BorderSide.strokeAlignInside,
          color: state == InfoRowState.critical ||
                  state == InfoRowState.criticalLoading
              ? AbiliaColors.red
              : state == InfoRowState.verified
                  ? AbiliaColors.green120
                  : AbiliaColors.white140,
        ),
        borderRadius: BorderRadius.circular(
          layout.infoRow.borderRadius,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: layout.infoRow.iconSize,
            color: state == InfoRowState.critical ||
                    state == InfoRowState.criticalLoading
                ? AbiliaColors.red120
                : AbiliaColors.black,
          ),
          Expanded(
            child: Tts(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: textColor),
              ),
            ).pad(layout.infoRow.titlePadding),
          ),
          if (state == InfoRowState.criticalLoading)
            SizedBox.square(
              dimension: layout.infoRow.iconSize,
              child: AbiliaProgressIndicator(
                strokeWidth: layout.infoRow.progressIndicatorStrokeWidth,
              ),
            ),
          if (state == InfoRowState.verified)
            Icon(
              AbiliaIcons.ok,
              size: layout.infoRow.iconSize,
              color: AbiliaColors.green120,
            ),
        ],
      ),
    );
  }
}
