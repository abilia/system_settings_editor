part of 'main_page.dart';

class AgendaHeader extends StatelessWidget {
  final bool expanded;
  final void Function(bool) onTap;

  const AgendaHeader({required this.onTap, required this.expanded, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 16),
      decoration: const ShapeDecoration(
        color: abiliaBlack90,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Lt.of(context).today, style: actionButtonTextStyle),
          ShowHideToggle(
            onTap: onTap,
            show: expanded,
          ),
        ],
      ),
    );
  }
}

class ShowHideToggle extends StatelessWidget {
  final bool show;
  final void Function(bool) onTap;
  const ShowHideToggle({
    required this.show,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(!show),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedCrossFade(
              duration: Agenda.animationDuration,
              firstChild: Text(Lt.of(context).hide, style: bodySmall),
              secondChild: Text(Lt.of(context).show, style: bodySmall),
              crossFadeState:
                  show ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: Agenda.animationDuration,
              transformAlignment: Alignment.center,
              transform: Matrix4.diagonal3Values(
                -1.0,
                show ? -1.0 : 1.0,
                1,
              )..rotateZ(.5 * pi),
              child: const Icon(
                AbiliaIcons.rollUp,
                color: abiliaWhite,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
